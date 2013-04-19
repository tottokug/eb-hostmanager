#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

cd /tmp
rm -rf node-*
curl $EB_CONFIG_NODEJS_URL | tar xz
cd node-*
for path in *; do
  [ -d $path ] && cp -Rf $path/* /usr/$path/
done
rm -rf /tmp/node-*
