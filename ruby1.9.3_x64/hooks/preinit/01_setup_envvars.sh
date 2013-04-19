#!/usr/bin/env bash

. /opt/elasticbeanstalk/support/envvars

SUPPORT_PATH=/opt/elasticbeanstalk/support
python $SUPPORT_PATH/build_envvars.py
ln -sf $SUPPORT_PATH/envvars /etc/profile.d/eb_envvars.sh
