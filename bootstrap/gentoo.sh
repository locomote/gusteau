#!/bin/sh

if type -p chef-solo > /dev/null; then
  echo "Using chef-solo at `which chef-solo`"
else
  emerge --sync

  echo 'RUBY_TARGETS="ruby19"' >> /etc/make.conf

  CONFIG_PROTECT_MASK="/etc/portage/" emerge --autounmask-write ruby:1.9
  emerge -uDN ruby:1.9
  revdep-rebuild

  gem install chef ruby-shadow --no-ri --no-rdoc
fi
