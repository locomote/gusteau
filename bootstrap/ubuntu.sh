#!/bin/sh

if type -p chef-solo > /dev/null; then
  echo "Using chef-solo at `which chef-solo`"
else
  apt-get install -y ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert curl rubygems
  gem install chef --no-ri --no-rdoc --version "=11.4.0"
fi
