Gusteau
=======

*"Anyone can cook."*

[![Build Status](https://www.travis-ci.org/locomote/gusteau.png?branch=master)](https://www.travis-ci.org/locomote/gusteau)
[![Dependency Status](https://gemnasium.com/locomote/gusteau.png)](https://gemnasium.com/locomote/gusteau)

Introduction
------------

Gusteau is here to make servers provisioning simple and enjoyable. It's a good choice if you are running a small infrastructure or a VPS and want to use Chef. It provides an efficient interface to Chef Solo as well as some nice features:

* Uses YAML for readable server configuration definitions
* Uses a single SSH connection to stream compressed files and commands
* Allows you to use normal Chef flags:
  * `-W` or `--why-run` (dry run mode)
  * `-l` for setting a log level and `-F` for setting an output formatter
* Is able to bootstrap CentOS, RHEL, Ubuntu and Gentoo systems with chef-solo.

Gettings started
----------------

Gusteau is a Ruby gem:

```
gem install gusteau
```

A typical Gusteau node configuration looks like this:

```
json:
  mysql:
    server_root_password: ASahiweqwqe2
  rvm:
    default_ruby: 1.9.3-p362
  users:
   - linguini

roles:
  - base

recipes:
  - mysql::server
  - iptables

server:
  host: 33.33.33.20
  platform: ubuntu
  password: omgsecret
```

Gusteau only needs a node definition to run, but you'll need a few cookbooks to actually cook something :)
The following command generates an example configuration to get you started:

```
gusteau init project-name
```

Next, `cd project-name` and see `nodes/example.yml`.


Provisioning a server
----------

The following command will run all roles and recipes from node's YAML file.

```
gusteau example provision
```

Use the `--bootstrap` or `-b` flag to bootstrap chef-solo (for the first time run).

Running recipes
-----------
You may choose to run a few recipes instead of full provisioning.

```
gusteau example run redis::server ntp unicorn
```

SSH
---
Gusteau provides a useful shortcut that you may use to ssh into a node. If you haven't got passwordless authentication set up, Gusteau will use `user` and `password` values from the node configuration.

```
gusteau ssh example
```

Please note that `expect` utility must be installed for `gusteau ssh` to work.

If you prefer calling ssh directly, you will find the `gusteau ssh_config` subcommand useful:

```
gusteau ssh_config >> ~/.ssh/config
```

Using with Vagrant
------------------
Gusteau can save you from writing some Vagrantfile boilerplate code. It also enables you to move node-specific Vagrant configuration away from the Vagrantfile into node yml files.

```
...
vagrant:
  IP: 192.168.100.20
  cpus: 1
  memory: 512
  box_url: 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
```

The following bit will configure Vagrant for all Gusteau nodes which have `vagrant` section defined.

```
Vagrant.configure('2') do |config|
  Gusteau::Vagrant.detect(config) do |setup|
    setup.prefix = 'loco'
    setup.defaults.box_url = 'http://example.com/vm/opscode_centos-6.4.box'
    setup.provision = false
  end
end
```

* The `prefix` option lets you prepend your VirtualBox VMs names, e.g. `loco-nodename`.
* The `defaults` one lets you provide default values for `cpus`, `memory`, `box_url`.
* If you'd like to use Vagrant's own automatic `chef_solo` provisioner, set `provision` to `true`. In this scenario, `gusteau provision` will be just calling `vagrant provision`.

Please note that the add-on only works with Vagrant ~> 1.2 and needs gusteau to be installed as a Vagrant plugin:

```
vagrant plugin install gusteau
```

Notes
-----

* Feel free to contribute a [bootstrap script](https://github.com/locomote/gusteau/tree/master/bootstrap) for your platform.
* Gusteau uploads  both `./cookbooks` and `./site-cookbooks` so that you can use [librarian-chef](https://github.com/applicationsonline/librarian) to include third party cookbooks.

