#!/usr/bin/env bash

[ "$EB_FIRST_RUN" != "true" ] && exit 0

. /opt/elasticbeanstalk/support/envvars

yum install -y gcc-c++ make tree subversion mercurial git-all dos2unix \
  curl-devel ruby-devel rubygems rubygem-json \
  libxml2-devel libxslt-devel mysql mysql-devel

if [ "$PHP_VERSION" = '5.4' ]; then
  echo "Configuring container for PHP 5.4"
  yum install -y php54-devel php54-bcmath php54-intl php54-mbstring \
    php54-gd php54-pecl-imagick \
    php54-mcrypt php54-mysqlnd php54-pdo php54-pgsql php54-odbc \
    php54-soap php54-xml php54-xmlrpc \
    php54-pecl-ssh2 php54-pecl-apc php54-pecl-memcache php54-pecl-memcached \
    php54-pecl-oauth php54-process uuid-php54
else
  echo "Configuring container for PHP 5.3"
  yum install -y php-devel php-bcmath php-intl php-mbstring \
    php-gd php-pecl-imagick \
    php-mcrypt php-mysqlnd php-pdo php-pgsql php-odbc \
    php-soap php-xml php-xmlrpc \
    php-pecl-ssh2 php-pecl-apc php-pecl-memcache php-pecl-memcached \
    php-pecl-oauth php-process uuid-php
fi
