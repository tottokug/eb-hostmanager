#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

# For builtin Rails logging support
ln -sf $EB_CONFIG_APP_CURRENT/log/production.log $EB_CONFIG_APP_LOGS/production.log
ln -sf $EB_CONFIG_APP_CURRENT/log/development.log $EB_CONFIG_APP_LOGS/development.log
