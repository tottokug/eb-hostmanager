#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

cd $EB_CONFIG_APP_ONDECK

if [ -f composer.json ]; then
  if [ -d vendor ]; then
    echo 'Found a composer.json file, but not installing because a vendor folder is present.'
  else
    echo 'Found composer.json file. Attempting to install vendors.'
    # If a composer.json file is present, then composer install
    composer.phar install --no-ansi --no-interaction $PHP_COMPOSER_OPTIONS || exit 1
  fi
else
  echo 'No composer.json file detected'
fi

true