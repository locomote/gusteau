#!/bin/sh
# Usage: omnibus.sh VERSION - installs the requested version of Chef, skipping if it's already installed

install_sh="https://www.opscode.com/chef/install.sh"
requested_version=$1

if type -p chef-solo > /dev/null && gem list -i chef -v $requested_version > /dev/null; then
  echo "Using chef-solo $requested_version at $(which chef-solo)"
else
  if command -v curl &>/dev/null; then
    curl -L "$install_sh" | sudo bash -s -- -v "$requested_version"
  elif command -v wget &>/dev/null; then
    wget -qO- "$install_sh" | sudo bash -s -- -v "$requested_version"
  else
    echo "Neither wget nor curl found. Please install one." >&2
    exit 1
  fi
fi
