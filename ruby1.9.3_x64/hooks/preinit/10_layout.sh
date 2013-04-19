#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

mkdir -p $EB_CONFIG_APP_CURRENT $EB_CONFIG_APP_SUPPORT/{logs,pids,assets}
mkdir -p /opt/elasticbeanstalk/tasks/{publishlogs,taillogs,bundlelogs,systemtaillogs}.d
