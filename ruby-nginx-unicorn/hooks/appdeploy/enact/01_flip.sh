#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

if [ -d $EB_CONFIG_APP_CURRENT ]; then
  rm -rf $EB_CONFIG_APP_CURRENT.old
  mv $EB_CONFIG_APP_CURRENT $EB_CONFIG_APP_CURRENT.old
  rm -rf $EB_CONFIG_APP_CURRENT.old &
fi

mv $EB_CONFIG_APP_ONDECK $EB_CONFIG_APP_CURRENT
su -c "mkdir -p $EB_CONFIG_APP_CURRENT/{tmp,public}" $EB_CONFIG_APP_USER
