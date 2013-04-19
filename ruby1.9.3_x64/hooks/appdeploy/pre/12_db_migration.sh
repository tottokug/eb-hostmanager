#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

[ "$RAILS_SKIP_MIGRATIONS" == "true" ] &&
  echo "Skipping database migrations (RAILS_SKIP_MIGRATIONS=true)." &&
  exit 0

cd $EB_CONFIG_APP_ONDECK
su -c "leader_only rake db:migrate" $EB_CONFIG_APP_USER ||
  echo "Rake task failed to run, skipping database migrations."

true
