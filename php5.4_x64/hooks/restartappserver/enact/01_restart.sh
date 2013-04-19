#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

# Since this is a failsafe, force a hard restart
service httpd restart
