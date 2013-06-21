#!/bin/sh

if type -p chef-solo > /dev/null; then
  echo "Using chef-solo $(chef-solo --v | awk '{print $2}') at $(which chef-solo)"
else
  emerge layman
  echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf

  layman -o https://raw.github.com/lxmx/gentoo-overlay/master/overlay.xml -f -a lxmx
  layman -S

  echo "app-admin/chef-omnibus ~amd64" >> /etc/portage/package.keywords
  emerge app-admin/chef-omnibus

  # Make non-interactive SSH sessions see environment variables
  if [[ ! `which chef-solo` ]]; then
    echo 'source /etc/profile' >> ~/.bashrc
    source ~/.bashrc
  fi
fi
