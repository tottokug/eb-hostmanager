#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

[ "$RAILS_SKIP_ASSET_COMPILATION" == "true" ] &&
  echo "Skipping asset compilation (RAILS_SKIP_ASSET_COMPILATION=true)." &&
  exit 0

cd $EB_CONFIG_APP_ONDECK
su -c "rake assets:precompile" $EB_CONFIG_APP_USER ||
  echo "Rake task failed to run, skipping asset compilation."

true
