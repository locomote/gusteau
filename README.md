# Gusteau

*"Anyone can cook."*

[![Build Status](https://www.travis-ci.org/locomote/gusteau.png?branch=master)](https://www.travis-ci.org/locomote/gusteau)
[![Coverage Status](https://coveralls.io/repos/locomote/gusteau/badge.png)](https://coveralls.io/r/locomote/gusteau)
[![Gem Version](https://badge.fury.io/rb/gusteau.png)](http://badge.fury.io/rb/gusteau)

Gusteau is an easy to use configuration manager for Chef Solo and Vagrant. It aims to:

* Provide existing Chef Solo users with a more efficient workflow
* Make Chef Solo usable for a small to mid scale multi-node setup
* Make Chef Solo more accessible for the new users

Some of the features include:

* YAML for readable, flexible infrastructure configuration
* Usage of a single SSH connection to stream compressed files and commands
* Support for normal Chef CLI flags:
  * `-W` or `--why-run` (dry run mode)
  * `-l` for setting a log level and   `-F` for setting an output formatter
* Bootstrapping target systems with Chef-Omnibus or custom scripts.


## Getting started

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
before:
  - bundle exec berks install --path ./cookbooks

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


## Converging a server

The following command will run the whole run_list on the node.

```
gusteau converge development-playground
```

Use the `--bootstrap` or `-b` flag to bootstrap chef-solo (e.g. during the first run).

## Applying individual recipes

You may choose to run a custom run_list instead of the full convergence.

```
gusteau apply development-playground "role[base],recipe[oh-my-zsh]"
```

## SSH

Gusteau provides a useful shortcut that you may use to ssh into a node. If you haven't got passwordless authentication set up, Gusteau will use `user` and `password` values from the node configuration.

```
gusteau ssh development-playground
```

Please note that `expect` utility must be installed for `gusteau ssh` to work.

If you prefer calling ssh directly, you will find the `gusteau ssh_config` subcommand useful:

```
gusteau ssh_config >> ~/.ssh/config
```

## Vagrant Plugin

Gusteau can save you from writing some Vagrantfile boilerplate code. It enables you to move node specific Vagrant configuration away from the Vagrantfile into node definitions. The Vagrant plugin for Gusteau means you can then bring up this node in VirtualBox.

```
development:
  nodes:
    www:
      vagrant:
        IP: 192.168.100.20
        cpus: 1
        memory: 512
        box_url: 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
```

The following snippet in the Vagrantfile configures Vagrant for all nodes (as above) listed in Gusteau which have `vagrant` sections defined.

```ruby
Vagrant.configure('2') do |config|
  Gusteau::Vagrant.detect(config) do |setup|
    setup.prefix = 'loco'
    setup.defaults.box_url = 'http://example.com/vm/opscode_centos-6.4.box'
  end
end
```

* The `prefix` option lets you prepend your VirtualBox VMs names, e.g. `loco-nodename`.
* The `defaults` one lets you provide default values for `cpus`, `memory`, `box_url`, `box`.

Please note that the add-on only works with Vagrant ~> 1.2 and needs Gusteau to be installed as a Vagrant plugin:

```
vagrant plugin install gusteau
```

Once the Gusteau plugin for Vagrant is installed you can start up VirtualBox using the environment and node data for vagrant in .gusteau.yml:

```
vagrant up development-www
```

## Configuration

### Before and after hooks

You can tell Gusteau to execute specific commands before and / or after `converge` or `apply` take place. They get executed on the host system. Example `.gusteau.yml` snippet:

```
before:
  - bundle exec librarian-chef install

after:
  - bundle exec rake spec
```

### Attributes
In addition to specifying `attributes` for environments you can set node-specifc ones. They will be deep-merged with environment ones:

```
environments:
  staging:
    attributes:
      hostname: staging
    nodes:
      one:
        attributes: { hostname: staging-one }
      two:
        attributes: { hostname: staging-two }
```

### Run lists

You can also override `run_list` for specific nodes.

### Bootstrap script

By default, Gusteau installs the [Omnibus Chef](http://www.opscode.com/chef/install/) 11.4.4. You can also set the Omnibus Chef version explicitly by specifying it in `.gusteau.yml`:

```
chef_version: 10.26.0
```

If you're targeting a non Omnibus-supported platform you might want to specify the `platform` value for a node: this invokes a specific [script](https://github.com/locomote/gusteau/tree/master/bootstrap).

Alternatively, you can specify a custom script in `.gusteau.yml`:

```
bootstrap: ./scripts/freebsd.sh
```


### Custom cookbooks path

By default, Gusteau uploads and sets Chef Solo up to use cookbooks from `./cookbooks` and `./site-cookbooks` directories. If it doesn't work for you, you can override these values in `.gusteau.yml`:

```
cookbooks_path: [ './my-cookbooks', '../something-else' ]
roles_path: './base-roles'
```
