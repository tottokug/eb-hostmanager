#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars
. /opt/elasticbeanstalk/support/util.sh

# Setup taillogs configuration
eb_template $EB_ROOT/support/conf/taillogs.conf > $EB_ROOT/tasks/taillogs.d/webapp.conf
eb_template $EB_ROOT/support/conf/taillogs.conf > $EB_ROOT/tasks/systemtaillogs.d/webapp.conf

# Setup bundlelogs and publishlogs
eb_template $EB_ROOT/support/conf/bundlelogs.conf > $EB_ROOT/tasks/bundlelogs.d/webapp.conf
eb_template $EB_ROOT/support/conf/publishlogs.conf > $EB_ROOT/tasks/publishlogs.d/webapp.conf

# Setup logrotate configuration
eb_template $EB_ROOT/support/conf/logrotate.conf > /etc/logrotate.d/webapp
