#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

passenger_dir=/var/lib/passenger-standalone

cd /var/lib
curl $EB_CONFIG_PASSENGER_URL | tar xz

# Patch spawner to reload envvars
cd $passenger_dir/*/support/lib/phusion_passenger/
mv spawn_manager.rb spawn_manager_orig.rb
cp $EB_ROOT/support/conf/passenger_spawn_manager.rb spawn_manager.rb

# Symlink new version of passenger in case GCC version changes
gcc_version=$(gcc -v 2>&1 | grep "gcc version" | awk '''{print $3}')
file=$(ls $passenger_dir)
newfile=$(ls /var/lib/passenger-standalone | sed -E 's/gcc[0-9]+\.[0-9]+\.[0-9]+/gcc'$gcc_version'/')
if [ ! -e $passenger_dir/$newfile ]; then
  ln -s $passenger_dir/* $passenger_dir/$newfile
fi

# Service script
cp $EB_ROOT/support/conf/passenger /etc/init.d/passenger
chmod +x /etc/init.d/passenger
ln -s ../init.d/passenger /etc/rc.d/rc3.d/S99passenger
