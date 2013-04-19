#!/bin/bash
#==============================================================================
# Copyright 2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#       http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#==============================================================================


function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

OUT=$(cp /tmp/deployment/config/tomcat7 /etc/sysconfig/tomcat7 2>&1)
RESULT=$?
if [[ $RESULT -ne 0 ]]; then
  if [[ "$EB_SYSTEM_STARTUP" != "true" ]];
  then
    error_exit "Failed to update tomcat sysconfig file: $OUT" $RESULT
  else
    echo "Failed to update tomcat sysconfig, not failing workflow on startup."
  fi
fi

