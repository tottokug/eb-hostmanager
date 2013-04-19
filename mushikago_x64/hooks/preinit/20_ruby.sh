#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

# Fix Ruby symlinks
if [ "$RUBY18_MODE" == "true" ]; then
  SUFFIX='1.8'
  mv /usr/bin/gem /usr/bin/gem$SUFFIX
  ln -sf /usr/bin/gem$SUFFIX /usr/bin/gem
else
  SUFFIX='1.9'
  ln -sf /usr/bin/ruby$SUFFIX /usr/bin/ruby
  ln -sf /usr/bin/gem$SUFFIX /usr/bin/gem
  ln -sf /usr/bin/irb$SUFFIX /usr/bin/irb
  ln -sf /usr/bin/rake$SUFFIX /usr/bin/rake
  ln -sf /usr/bin/rdoc$SUFFIX /usr/bin/rdoc
fi
