#!/bin/sh

if type -p chef-solo > /dev/null; then
  echo "Using chef-solo at `which chef-solo`"
else
  rpm -Uvh http://rbel.frameos.org/rbel6
  yum-config-manager --enable rhel-6-server-optional-rpms
  yum install -y ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode
  cd /tmp
  curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
  tar zxf rubygems-1.8.10.tgz
  cd rubygems-1.8.10
  ruby setup.rb --no-format-executable
  gem install chef --no-ri --no-rdoc --version "=11.4.0"
fi
