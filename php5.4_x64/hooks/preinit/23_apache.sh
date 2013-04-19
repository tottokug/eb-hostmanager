#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

# Create the upstart script for apache
cp /opt/elasticbeanstalk/support/conf/httpd/httpd_upstart /etc/init/httpd.conf

# Create the init.d upstart proxy script to manage apache using service
cp /opt/elasticbeanstalk/support/conf/httpd/httpd_init /etc/init.d/httpd
chmod +x /etc/init.d/httpd

# Create symlink for /var/www/html to /var/app
rm -rfv /var/www/html || exit 1
ln -sfv /var/app/current /var/www/html || exit 1

# Ensure that the public folder is present so Apache can start with a default documet root
mkdir -p $EB_CONFIG_APP_CURRENT/$PHP_DOCUMENT_ROOT

# Use environment variables with Apache. Apache will source /etc/sysconfig/httpd
# before starting, and the variables exported in this file can be used directly
# in Apache configuration files. These variables will also be available to PHP
# using the $ENV[''] superglobal.
# See: http://serverfault.com/a/64663
grep -q '/opt/elasticbeanstalk/support/envvars' /etc/sysconfig/httpd || echo '. /opt/elasticbeanstalk/support/envvars' >> /etc/sysconfig/httpd

# Ensure that apache runs as the Beanstalk user
sed -i 's/User .*/User ${EB_CONFIG_APP_USER}/g' /etc/httpd/conf/httpd.conf
sed -i 's/Group .*/User ${EB_CONFIG_APP_USER}/g' /etc/httpd/conf/httpd.conf

# Add PHP to the DirectoryIndex
sed -i 's/DirectoryIndex .*/DirectoryIndex index.php index.html/g' /etc/httpd/conf/httpd.conf

# Update the httpd.conf file to enable the use of .htaccess
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Disable directory indexing
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' /etc/httpd/conf/httpd.conf

# Configure Apache for AWS if it has not been already

if grep -q 'AWS Settings' /etc/httpd/conf/httpd.conf; then
  echo 'Apache is already configured'
else
    cat >> /etc/httpd/conf/httpd.conf <<END_OF_TEXT

#### AWS Settings ####

# Disable ETag headers
FileETag none

# Hide Apache and PHP info
Header unset Server
Header unset X-Powered-By

# Don't expose server versions
ServerSignature Off
ServerTokens Prod

# Enable server-status for internal IP
<Location /server-status>
   SetHandler server-status
   Order Deny,Allow
   Deny from all
   Allow from 127.0.0.1
</Location>

# KeepAlive: Whether or not to allow persistent connections (more than
# one request per connection). Set to "Off" to deactivate.
KeepAlive On

# Configure /var/www/html
<Directory "/var/www/html">
    Options FollowSymLinks
    AllowOverride All
    DirectoryIndex index.html index.php
    Order allow,deny
    Allow from all
</Directory>

#### End of AWS Settings ####

END_OF_TEXT
fi

# Add better mime-types
cp /opt/elasticbeanstalk/support/conf/httpd/add-types.conf /etc/httpd/conf.d/add-types.conf

# Disable unused modules. If they don't exist, then that's fine because it 
# probably means this script has already run
mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.disabled 2>/dev/null || true
mv /etc/httpd/conf.modules.d/00-lua.conf /etc/httpd/conf.modules.d/00-lua.conf.disabled 2>/dev/null || true
mv /etc/httpd/conf.modules.d/00-dav.conf /etc/httpd/conf.modules.d/00-dav.conf.disabled 2>/dev/null || true
mv /etc/httpd/conf.modules.d/01-cgi.conf /etc/httpd/conf.modules.d/01-cgi.conf.disabled 2>/dev/null || true
# Disable unused config files, and again, allow them to fail silently if this 
# script has already run
mv /etc/httpd/conf.d/autoindex.conf /etc/httpd/conf.d/autoindex.conf.disable 2>/dev/null || true
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.disable 2>/dev/null || true
