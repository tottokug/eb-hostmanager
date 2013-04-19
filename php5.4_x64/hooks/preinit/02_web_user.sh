#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

adduser -m -l $EB_CONFIG_APP_USER || echo "${EB_CONFIG_APP_USER} user already exists"
