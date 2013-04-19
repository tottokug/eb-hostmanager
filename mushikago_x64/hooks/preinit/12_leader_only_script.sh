#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

cp $EB_ROOT/support/conf/leader_only /usr/bin/leader_only
chmod +x /usr/bin/leader_only
