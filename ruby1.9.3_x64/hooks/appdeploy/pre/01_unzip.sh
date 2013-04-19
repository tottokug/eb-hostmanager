#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

mkdir -p $EB_CONFIG_APP_BASE && chown $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER $EB_CONFIG_APP_BASE
[ -d $EB_CONFIG_APP_ONDECK ] && rm -rf $EB_CONFIG_APP_ONDECK
su -c "/usr/bin/unzip -d $EB_CONFIG_APP_ONDECK $EB_CONFIG_SOURCE_BUNDLE" $EB_CONFIG_APP_USER
chmod 775 $EB_CONFIG_APP_ONDECK
