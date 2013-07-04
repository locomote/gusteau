Gusteau
=======

*"Anyone can cook."*

[![Build Status](https://www.travis-ci.org/locomote/gusteau.png?branch=master)](https://www.travis-ci.org/locomote/gusteau)
[![Coverage Status](https://coveralls.io/repos/locomote/gusteau/badge.png)](https://coveralls.io/r/locomote/gusteau)
[![Dependency Status](https://gemnasium.com/locomote/gusteau.png)](https://gemnasium.com/locomote/gusteau)

Introduction
------------

Gusteau is an easy to use configuration manager for Chef Solo and Vagrant.
It aims to:
	
1. Provide Chef Solo users with a more efficient workflow
2. Encourage new users to try and to switch to Chef by avoiding the complexity of Chef Server.

Some of the features include:

* YAML for readable infrastructure configuration
* Usage of a single SSH connection to stream compressed files and commands
* Support for normal Chef CLI flags:
  * `-W` or `--why-run` (dry run mode)
  * `-l` for setting a log level and   `-F` for setting an output formatter
* Bootstrapping target systems with Chef-Omnibus or custom scripts.

Gettings started
----------------

Gusteau is a Ruby gem:

```
gem install gusteau
```

The following command generates an example Chef-repo:

```
gusteau init project-name
```

Make sure you read through `project-name/README.md` first.

A typical `.gusteau.yml` looks like this:

```
environments:
  development:
    attributes:
      mysql:
        server_root_password: ASahiweqwqe2
      rvm:
        default_ruby: 1.9.3-p362
      users:
       - linguini

    run_list:
      - role[base]
      - recipe[mysql::server]
      - recipe[iptables]

    nodes:
      playground:
        host: 33.33.33.20
        password: omgsecret
```


Converging a server
----------

The following command will run the whole run_list on the node.

```
gusteau converge development-playground
```

Use the `--bootstrap` or `-b` flag to bootstrap chef-solo (e.g. during the first run).

Applying individual recipes
-----------
You may choose to run a custom run_list instead of the full convergence.

```
gusteau apply development-playground "role[base],recipe[oh-my-zsh]"
```

SSH
---
Gusteau provides a useful shortcut that you may use to ssh into a node. If you haven't got passwordless authentication set up, Gusteau will use `user` and `password` values from the node configuration.

```
gusteau ssh development-playground
```

Please note that `expect` utility must be installed for `gusteau ssh` to work.

If you prefer calling ssh directly, you will find the `gusteau ssh_config` subcommand useful:

```
gusteau ssh_config >> ~/.ssh/config
```

Using with Vagrant
------------------
Gusteau can save you from writing some Vagrantfile boilerplate code. It also enables you to move node-specific Vagrant configuration away from the Vagrantfile into node definitions.

```
...
nodes:
  www:
    vagrant:
      IP: 192.168.100.20
      cpus: 1
      memory: 512
      box_url: 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
```

The following snippet configures Vagrant for all Gusteau nodes which have `vagrant` sections defined.

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
* If you'd like to use Vagrant's own automatic `chef_solo` provisioner, set `provision` to `true`. *Not recommended* unless you really know what you are doing.

Please note that the add-on only works with Vagrant ~> 1.2 and needs gusteau to be installed as a Vagrant plugin:

```
vagrant plugin install gusteau
```

Notes
-----

* Feel free to contribute a [bootstrap script](https://github.com/locomote/gusteau/tree/master/bootstrap) for your platform.


