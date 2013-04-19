#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

if [ "$RUBY18_MODE" == "true" ]; then
  RUBY_PACKAGES='rubygems ruby-devel'
else
  RUBY_PACKAGES='rubygems19 ruby19-devel'
fi
yum install -y gcc-c++ make $RUBY_PACKAGES \
  curl-devel libxml2-devel libxslt-devel sqlite-devel mysql mysql-devel ImageMagick ImageMagick-devel
