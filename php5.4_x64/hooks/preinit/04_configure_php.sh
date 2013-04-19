#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

# Update PHP and apache configurations to use environment variables
# Updates php.ini and the DocumentRoot of apache
php /opt/elasticbeanstalk/support/php_apache_env.php

[ "$EB_FIRST_RUN" != "true" ] && exit 0

echo "First run. Configuring PHP."

# Calculates the most appropriate APC shm size based on the instance type
function calculate_shm_size()
{
  case `curl -s http://169.254.169.254/latest/meta-data/instance-type` in
    t1.micro)
      shm_size='64M'
      ;;
    m1.small)
      shm_size='128M'
      ;;
    c1.medium)
      shm_size='128M'
      ;;
    *)
      shm_size='256M'
      ;;
  esac
}

# Add recommended settings to php.ini if they are not already set
if grep -q 'AWS Settings' /etc/httpd/conf/httpd.conf; then
  echo 'PHP is already configured'
else
    cat >> /etc/php.ini <<END_OF_TEXT

; AWS Settings
expose_php = Off
html_errors = Off
variables_order = "EGPCS"
session.save_path = "/tmp"
default_socket_timeout = 90
post_max_size = 32M
short_open_tag = 1
date.timezone = UTC
; End of AWS Settings

END_OF_TEXT
fi

# Update apc.ini on preinit
calculate_shm_size
sed -i "s/apc.shm_size=.*/apc.shm_size=${shm_size}/g" /etc/php.d/apc.ini
sed -i "s/apc.num_files_hint=.*/apc.num_files_hint=10000/g" /etc/php.d/apc.ini
sed -i "s/apc.user_entries_hint=.*/apc.user_entries_hint=10000/g" /etc/php.d/apc.ini
sed -i "s/apc.max_file_size=.*/apc.max_file_size=5M/g" /etc/php.d/apc.ini

# Copy the PHPUnit Phar file to the path
cp /opt/elasticbeanstalk/support/phpunit.phar /usr/bin/phpunit.phar || true
