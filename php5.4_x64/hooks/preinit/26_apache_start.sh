#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

# Restart apache
initctl start httpd || echo 'Apache is already running'
