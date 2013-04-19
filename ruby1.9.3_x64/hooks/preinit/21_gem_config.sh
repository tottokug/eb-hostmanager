#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

cp $EB_ROOT/support/conf/gemrc /etc/gemrc

# Remove broken operating_system.rb hook in rubygems packaged with AMI
# See https://github.com/luislavena/sqlite3-ruby/issues/70
[ -f /usr/share/rubygems1.9/rubygems/defaults/operating_system.rb ] &&
mv /usr/share/rubygems1.9/rubygems/defaults/operating_system.rb \
   /usr/share/rubygems1.9/rubygems/defaults/operating_system.rb.off ||
true
