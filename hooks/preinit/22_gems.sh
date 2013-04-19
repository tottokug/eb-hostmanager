#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

cd /tmp && rm -f *.gem

SOURCE=$(gem sources -l | tail -n 1)
gem fetch --source $SOURCE rack -v 1.4.1
gem fetch --source $SOURCE rake -v 0.9.2.2
gem fetch --source $SOURCE fastthread -v 1.0.7
gem fetch --source $SOURCE daemon_controller -v 1.0.0
gem fetch --source $SOURCE json -v 1.7.5
gem fetch --source $SOURCE bundler -v 1.2.1
gem fetch --source $SOURCE passenger -v 3.0.17
gem fetch --source $SOURCE bigdecimal -v 1.1.0

md5sum -c $EB_ROOT/support/gems.md5sums.txt || exit $?

[ "$RUBY18_MODE" == "true" ] && rm -f bigdecimal-1.1.0.gem

gem install --local *.gem &&

rm -f *.gem
