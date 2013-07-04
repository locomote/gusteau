Gusteau
=======

*"Anyone can cook."*

[![Build Status](https://www.travis-ci.org/locomote/gusteau.png?branch=master)](https://www.travis-ci.org/locomote/gusteau)
[![Coverage Status](https://coveralls.io/repos/locomote/gusteau/badge.png)](https://coveralls.io/r/locomote/gusteau)
[![Dependency Status](https://gemnasium.com/locomote/gusteau.png)](https://gemnasium.com/locomote/gusteau)

Introduction
------------

Gusteau is an easy to use configuration manager for Chef Solo and Vagrant. It provides an efficient interface to Chef Solo as well as some nice features:

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
gem install gusteau --pre
```

A typical Gusteau configuration looks like this:

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

Gusteau only needs a single node definition to run, but you'll need a few cookbooks to actually cook something :)
The following command generates an example configuration to get you started:

```
gusteau init project-name
```

Next, `cd project-name` and see `.gusteau.yml`.


Converging a server
----------

The following command will run all roles and recipes from node's YAML file.

```
gusteau converge development-playground
```

Use the `--bootstrap` or `-b` flag to bootstrap chef-solo (for the first time run).

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
* If you'd like to use Vagrant's own automatic `chef_solo` provisioner, set `provision` to `true`.

Please note that the add-on only works with Vagrant ~> 1.2 and needs gusteau to be installed as a Vagrant plugin:

```
vagrant plugin install gusteau
```

Notes
-----

* Feel free to contribute a [bootstrap script](https://github.com/locomote/gusteau/tree/master/bootstrap) for your platform.
* Gusteau uploads `./cookbooks` and `./site-cookbooks` from the current working directory.

