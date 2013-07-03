#!/bin/bash

echo "Installing gem dependencies"
bundle

echo "Downloading cookbooks"
bundle exec berks install --path ./cookbooks

echo "Downloading Vagrant plugins"
vagrant plugin install vagrant-omnibus
vagrant plugin install gusteau

echo "Done!\nYou can now run 'vagrant up' and then 'gusteau converge example-box'"
