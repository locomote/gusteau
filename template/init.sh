#!/bin/bash -e

info()  { echo -e "\033[00;35m-----> $1\033[0m"; }
error() { echo -e "\033[00;31m$1\033[0m"; }
ok()    { echo -e "\033[00;32m$1\033[0m"; }

info "Installing gem dependencies..."
bundle

if [ ! $(vagrant -v | cut -f3 -d ' ' | cut -f2 -d '.') = "2" ]; then
  error "Sorry, 'gusteau init' only works with Vagrant 1.2.x"
  exit 1
fi

vagrant_boxes_dir="~/.vagrant.d/boxes"
if [ -d "$vagrant_boxes_dir/opscode-ubuntu-13.04" ] &&
   [ ! -d "$vagrant_boxes_dir/example-box"]; then

    info "Found the opscode-ubuntu-13.04 box, creating a copy"
    cp -R "$vagrant_boxes_dir/{opscode-ubuntu-13.04,example-box}"
fi

info "Installing Vagrant plugins..."
vagrant plugin install vagrant-omnibus
vagrant plugin install gusteau

info "Done!\n"

ok "Happy cooking with\n"
ok "             _/_          "
ok " _,  , , (   /  _  __,  , ,"
ok "(_)_(_/_/_)_(__(/_(_/(_(_/_"
ok " /|                        "
ok "(/"
ok "\nYou can now 'cd $1/', 'vagrant up' and then 'gusteau converge example-box'"
