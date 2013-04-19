#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

chown -R $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER $EB_CONFIG_APP_BASE
chown -R $EB_CONFIG_APP_USER:$EB_CONFIG_APP_USER $EB_CONFIG_APP_LOGS
