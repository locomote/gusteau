#!/bin/bash

echo "Installing gem dependencies"
bundle

echo "Downloading cookbooks"
bundle exec berks install --path ./cookbooks

if [ ! $(vagrant -v | cut -f3 -d ' ' | cut -f2 -d '.') = "2" ]; then
  echo "Sorry, 'gusteau init' only works with Vagrant 1.2.x"
  exit 1
fi

vagrant_boxes_dir="~/.vagrant.d/boxes"
if [ -d "$vagrant_boxes_dir/opscode-ubuntu-13.04" ] &&
   [ ! -d "$vagrant_boxes_dir/example-box"]; then

    echo "Found the opscode-ubuntu-13.04 box, creating a copy"
    cp -R "$vagrant_boxes_dir/{opscode-ubuntu-13.04,example-box}"
fi

echo "Installing Vagrant plugins"
vagrant plugin install vagrant-omnibus
vagrant plugin install gusteau

echo "Done!"
echo "You can now run 'vagrant up' and then 'gusteau converge example-box'"
