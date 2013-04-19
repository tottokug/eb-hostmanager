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


set -x

function preinit() {

TOMCAT7_HOME=/usr/share/tomcat7
TOMCAT7_CONF_HOME=/etc/tomcat7

echo "Patching Tomcat 7 startup scripts"
if [ -f /opt/elasticbeanstalk/containerfiles/tomcat7-elasticbeanstalk ]; then
    echo "Installing tomcat7-elasticbeanstalk script"
    /bin/mv /opt/elasticbeanstalk/containerfiles/tomcat7-elasticbeanstalk /usr/sbin
    /bin/chown root:root /usr/sbin/tomcat7-elasticbeanstalk
    /bin/chmod 755 /usr/sbin/tomcat7-elasticbeanstalk
    echo "Fixing Tomcat 7 init.d script"
    /bin/sed -i -e 's/\/usr\/sbin\/tomcat7/\/usr\/sbin\/tomcat7-elasticbeanstalk/g' /etc/init.d/tomcat7
fi

# Apache config

echo "Creating ElasticBeanstalk Apache confs"

/bin/cat > /etc/httpd/conf.d/elasticbeanstalk.conf <<EOELASTICBEANSTALKSITE
<VirtualHost *:80>
  <Proxy *>
    Order deny,allow
    Allow from all
  </Proxy>

  ProxyPass / http://localhost:8080/ retry=0
  ProxyPassReverse / http://localhost:8080/
  ProxyPreserveHost on

  LogFormat "%h (%{X-Forwarded-For}i) %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
  ErrorLog /var/log/httpd/elasticbeanstalk-error_log
  TransferLog /var/log/httpd/elasticbeanstalk-access_log
</VirtualHost>
EOELASTICBEANSTALKSITE

# Tomcat misc config

## X-Forwarded-For support

echo "Adding X-Forwarded-Proto valve"
/bin/sed -i -e '/<\/Host>/ i\
        <Valve className="org.apache.catalina.valves.RemoteIpValve" protocolHeader="X-Forwarded-Proto" \/>
' $TOMCAT7_CONF_HOME/server.xml

echo "Removing tomcat internal log rotation."
/bin/sed -i -e 's|prefix="localhost_access_log.*$|prefix="localhost_access_log" suffix=".txt" rotatable="false"|' $TOMCAT7_CONF_HOME/server.xml


# Tomcat logging
cat > /etc/logrotate.conf.elasticbeanstalk <<EOLOGROTATE
/var/log/tomcat7/catalina.out /var/log/tomcat7/localhost_access_log.txt {
    size 1M
    missingok
    rotate 5
    compress
    notifempty
    copytruncate
    dateext
    dateformat -%s
}
EOLOGROTATE

cat > /etc/logrotate.conf.elasticbeanstalk.httpd <<EOLOGROTATE2

/var/log/httpd/*log {
    size 100M
    missingok
    rotate 9
    compress
    notifempty
    dateext
    dateformat -%s
    sharedscripts
    delaycompress
    create 
    postrotate
        /sbin/service httpd reload > /dev/null 2>/dev/null || true
    endscript
}
EOLOGROTATE2

## Setup hourly cron to rotate logs
## Set -f so that these logs are rotated every time. 
cat > /etc/cron.hourly/logrotate-elasticbeanstalk <<EOLOGCRON
#!/bin/sh
test -x /usr/sbin/logrotate || exit 0
/usr/sbin/logrotate -f /etc/logrotate.conf.elasticbeanstalk
EOLOGCRON
chmod 755 /etc/cron.hourly/logrotate-elasticbeanstalk

## Setup hourly cron to rotate logs (do not set -f)
cat > /etc/cron.hourly/logrotate-elasticbeanstalk-httpd <<EOLOGCRON2
#!/bin/sh
test -x /usr/sbin/logrotate || exit 0
/usr/sbin/logrotate /etc/logrotate.conf.elasticbeanstalk.httpd
EOLOGCRON2
chmod 755 /etc/cron.hourly/logrotate-elasticbeanstalk-httpd

echo "Removing default tomcat logrotate."
/bin/rm /etc/logrotate.d/tomcat7

echo "Removing default httpd logrotate."
/bin/rm /etc/logrotate.d/httpd

echo "Removing extra log file."
sed -i '/.handlers = 1catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandle/c \
.handlers = java.util.logging.ConsoleHandler' /etc/tomcat7/logging.properties
sed -i '/org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].handlers = 2localhost.org.apache.juli.FileHandler/c \
org.apache.catalina.core.ContainerBase.[Catalina].[localhost].handlers = java.util.logging.ConsoleHandler' /etc/tomcat7/logging.properties

# Make sure commons pool is available to tomcat.
ln -sf /usr/share/java/apache-commons-pool.jar /usr/share/tomcat7/lib/

}

if [[ -n "$EB_FIRST_RUN" ]];
then
  echo "Running preinit"
  preinit
else
  echo "Running preinit-reboot"
fi
