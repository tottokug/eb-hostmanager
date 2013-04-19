#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

cd $EB_CONFIG_APP_ONDECK

# Ensure that apache owns the application folder and logs
chown -R $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER $EB_CONFIG_APP_BASE
chown -R $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER $EB_CONFIG_APP_LOGS
chown -R $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER /var/log/httpd

# If the user is using Symfony, then fix permissions
if [ -f app/SymfonyRequirements.php ]; then
  echo 'Ensuring that Symfony2 cache and log dir are writable by webapp'
  # Add permissions for symfony so that overwriting with root will retain user
  setfacl -R -m u:webapp:rwx -m u:root:rwx app/cache app/logs || true
  setfacl -dR -m u:webapp:rwx -m u:root:rwx app/cache app/logs || true
  # Fix Symfony permissions after composer post scripts
  chmod -R 1755 ./app/{cache,logs}
fi
