#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

cd $EB_CONFIG_APP_ONDECK
[ -f Gemfile ] && (bundle install || exit 1)
[ -f Gemfile.lock ] && chown $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER Gemfile.lock

true
