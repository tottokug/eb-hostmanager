#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

# Install PEAR package
yum install -y php-channel-amazon php-channel-ezc php-channel-phpunit \
 php-channel-symfony php-symfony-YAML

# Configure PEAR so that extensions know where php.ini is and install properly
pear config-create /root /root/.pearrc
pear config-set php_ini /etc/php.ini user
pear config-set auto_discover 1 user
pear config-set php_ini /etc/php.ini system
pear config-set auto_discover 1 system
