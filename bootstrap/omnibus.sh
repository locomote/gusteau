#!/bin/sh

install_sh="https://www.opscode.com/chef/install.sh"
version="11.4.4"

if type -p chef-solo > /dev/null; then
  echo "Using chef-solo $(chef-solo --v | awk '{print $2}') at $(which chef-solo)"
else
  if command -v curl &>/dev/null; then
    curl -L "$install_sh" | sudo bash -s -- -v "$version"
  elif command -v wget &>/dev/null; then
    wget -qO- "$install_sh" | sudo bash -s -- -v "$version"
  else
    echo "Neither wget nor curl found. Please install one." >&2
    exit 1
  fi
fi
