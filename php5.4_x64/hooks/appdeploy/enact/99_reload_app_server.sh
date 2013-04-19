#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

if [ "$EB_FIRST_RUN" = "true" ]; then
  # Hard restart on first app deploy
  service httpd restart
else
  # Graceful restart on other app deploys
  service httpd graceful
fi
