#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

[ "$RUBY18_MODE" == "true" ] && echo No bigdecimal fix in 1.8 && exit 0

# Remove the "bigdecimal" symlink installed by Linux AMI
BIGDECIMAL_LINK=/usr/share/ruby/1.9/bigdecimal
[ -L $BIGDECIMAL_LINK ] && rm -f $BIGDECIMAL_LINK

# Vendor bigdecimal instead of requiring it as a gem
BIGDECIMAL_PATH=/usr/share/ruby/1.9/gems/1.9.1/gems/bigdecimal-1.1.0
cp -R $BIGDECIMAL_PATH/lib/bigdecimal $BIGDECIMAL_PATH/bigdecimal.so /usr/share/ruby/1.9/

true