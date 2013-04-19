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

OUT=$(rm -rf /tmp/deployment/application/ROOT/.ebextensions/ 2>&1) || echo "Failed to remove .ebextensions from tmp directory."
OUT=$(cp -R /tmp/deployment/application/ROOT /var/lib/tomcat7/webapps/ROOT 2>&1; chown -R tomcat:tomcat /var/lib/tomcat7/webapps/ROOT  2>&1;)
RESULT=$?
if [[ $RESULT -ne 0 ]]; then
  if [[ "$EB_SYSTEM_STARTUP" != "true" ]];
  then
    error_exit "Failed to move application into destination.  Your application may be in an inconsistent state: $OUT" $RESULT
  else
    echo "Copy failed but not failing deploy on startup."
  fi
fi
