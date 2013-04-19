#!/bin/env php
<?php
/**
 * Because Apache is sometimes restarted using graceful restarted, changes to
 * environment variables don't automatically take effect in child processes. We
 * get around this by creating an Apache conf that explicitly calls SetEnv with
 * the values found in the environment variables of the ElasticBeanstalk
 * configuration file. Updating these variables also updates the variables used
 * by PHP after a graceful restart.
 */

$config = getConfig();
determineDocumentRoot($config);
cleanDocumentRoot($config);
writeApache($config);
writePhp($config);

/**
 * Grab the server configuration as an array
 *
 * @return array
 */
function getConfig()
{
    $json = json_decode(file_get_contents('/opt/elasticbeanstalk/deploy/configuration/containerconfiguration'), true);

    // Start with the hash from env
    $config = $json['env'];

    // the environment key is not a hash, but an array
    foreach ($json['php']['env'] as $env) {
        list($name, $value) = explode('=', $env);
        $config[$name] = $value;
    }

    if (getenv('RDS_HOSTNAME')) {
        echo 'RDS environment variables detected. Exporting variables into $_SERVER' . "\n";
        $config['RDS_HOSTNAME'] = getenv('RDS_HOSTNAME');
        $config['RDS_USERNAME'] = getenv('RDS_USERNAME');
        $config['RDS_PASSWORD'] = getenv('RDS_PASSWORD');
        $config['RDS_DB_NAME'] = getenv('RDS_DB_NAME');
        $config['RDS_PORT'] = getenv('RDS_PORT');
    }

    // Setting the timezone manually for now, waiting on Beanstalk to implement timezone as part of the service
    $config['PHP_DATE_TIMEZONE'] = 'UTC';

    return $config;
}

/**
 * Auto-detects the appropriate document root setting if one is not specified
 *
 * @param array $config Configuration settings passed by reference
 */
function determineDocumentRoot(&$config)
{
    if (!empty($config['PHP_DOCUMENT_ROOT'])) {
        echo "Using configuration value for DocumentRoot: {$config['PHP_DOCUMENT_ROOT']}\n";
        return;
    }

    $message = "Auto-detecting DocumentRoot - ";
    // Determine the appropriate root folder to check
    $rootFolder = file_exists(getenv('EB_CONFIG_APP_ONDECK')) ? getenv('EB_CONFIG_APP_ONDECK') : getenv('EB_CONFIG_APP_CURRENT');

    $checks = array(
        "{$rootFolder}/app/webroot" => array(
            'description' => 'Detected a CakePHP installation',
            'target'      => '/app/webroot'
        ),
        "{$rootFolder}/index.php" => array(
            'description' => 'Found a /index.php file',
            'target'      => '/'
        ),
        "{$rootFolder}/public" => array(
            'description' => 'Found a /public webroot folder',
            'target'      => '/public'
        ),
        "{$rootFolder}/wordpress" => array(
            'description' => 'Detected a WordPress installation',
            'target'      => '/wordpress'
        ),
        "{$rootFolder}/web" => array(
            'description' => 'Detected a Symfony2 standard edition installation',
            'target'      => '/web'
        ),
        '/var/www/html' => array(
            'description' => 'Could not auto-detect application. Defaulting to /',
            'target'      => '/'
        )
    );

    foreach ($checks as $path => $check) {
        if (file_exists($path)) {
            $message .= "{$check['description']}: Setting DocumentRoot to {$check['target']}";
            $config['PHP_DOCUMENT_ROOT'] = $check['target'];
            break;
        }
    }

    echo $message . " (Specify a DocumentRoot setting to disable auto-detection).\n";
}

/**
 * Cleans up the DocumentRoot setting if needed
 *
 * @param array $config Configuration array passed by reference
 */
function cleanDocumentRoot(&$config)
{
    // Make sure that the document root starts with a forward slash
    if (substr($config['PHP_DOCUMENT_ROOT'], 0, 1) != '/') {
        // Ensure that there's a leading slash
        $config['PHP_DOCUMENT_ROOT'] = '/' . $config['PHP_DOCUMENT_ROOT'];
    }
}

/**
 * Write the aws_env.conf file containing up to date environment variables
 * Update httpd.conf to update the environment variables in the file
 */
function writeApache(array $config)
{
    // Update the apache environment variables
    $output = '';
    foreach ($config as $name => $value) {
        $value = addslashes($value);
        $output .= "SetEnv {$name} \"" . addslashes($value) . "\"\n";
    }

    file_put_contents('/etc/httpd/conf.d/aws_env.conf', $output);

    // Update /etc/httpd/conf/httpd.conf
    $conf = file_get_contents('/etc/httpd/conf/httpd.conf');
    // Update apache to use the user-supplied document root
    $conf = preg_replace('/DocumentRoot "*.*"*/', "DocumentRoot \"/var/www/html{$config['PHP_DOCUMENT_ROOT']}\"", $conf);
    file_put_contents('/etc/httpd/conf/httpd.conf', $conf);
}

/**
 * Update the php.ini file with the most up to date environment variables
 */
function writePhp($config)
{
    // Maintain BC compatibility with the old container by providing a /etc/php.d/environment.ini file
    // Add old option values for BC compatibility
    $output = '';
    foreach ($config as $name => $value) {
        $output .= $name . '="' . addslashes($value) . "\"\n";
        $output .= 'aws.' . strtolower($name) . '="' . addslashes($value) . "\"\n";
    }
    // Add BC for access key and secret
    $output .= "aws.access_key=\"{$config['AWS_ACCESS_KEY_ID']}\"\n";
    $output .= "aws.secret_key=\"{$config['AWS_SECRET_KEY']}\"\n";
    $output .= 'aws.log_dir="' . getenv('EB_CONFIG_APP_LOGS') . '"' . "\n";
    // Add BC for params
    for ($i = 1; $i < 6; $i++) {
        $output .= "aws.param{$i}=\"" . addslashes($config["PARAM{$i}"]) . "\"\n";
    }
    file_put_contents('/etc/php.d/environment.ini', $output);

    // Massage booleans into On or Off
    $config['PHP_DISPLAY_ERRORS'] = filter_var($config['PHP_DISPLAY_ERRORS'], FILTER_VALIDATE_BOOLEAN) ? 'On' : 'Off';
    $config['PHP_ZLIB_OUTPUT_COMPRESSION'] = filter_var($config['PHP_ZLIB_OUTPUT_COMPRESSION'], FILTER_VALIDATE_BOOLEAN) ? 'On' : 'Off';
    $config['PHP_ALLOW_URL_FOPEN'] = filter_var($config['PHP_ALLOW_URL_FOPEN'], FILTER_VALIDATE_BOOLEAN) ? 'On' : 'Off';

    // Update the /etc/php.d/aws.ini file
    $ini = <<<EOT
; This file is auto-generated based on configuration settings
max_execution_time = {$config['PHP_MAX_EXECUTION_TIME']}
memory_limit = {$config['PHP_MEMORY_LIMIT']}
display_errors = {$config['PHP_DISPLAY_ERRORS']}
allow_url_fopen = {$config['PHP_ALLOW_URL_FOPEN']}
zlib.output_compression = {$config['PHP_ZLIB_OUTPUT_COMPRESSION']}

EOT;

    file_put_contents('/etc/php.d/aws.ini', $ini);
}
