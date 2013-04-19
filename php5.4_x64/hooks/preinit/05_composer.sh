#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

if [ ! -f /usr/bin/composer.phar ]; then
  ln -sf /opt/elasticbeanstalk/support/composer.phar /usr/bin/composer.phar
  chown $EB_CONFIG_APP_USER /usr/bin/composer.phar && chmod +x /usr/bin/composer.phar
fi
