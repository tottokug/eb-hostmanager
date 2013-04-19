#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

# Hard restart on all config deploys
service httpd restart
