Gusteau
=======

*"Anyone can cook."*

[![Build Status](https://www.travis-ci.org/locomote/gusteau.png?branch=master)](https://www.travis-ci.org/locomote/gusteau)

Introduction
------------

Gusteau is here to make servers provisioning simple and enjoyable. It provides an efficient interface to Chef Solo as well as some nice features:

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

```YAML
json:
  mysql:
    server_root_password: ASahiweqwqe2
  rvm:
    default_ruby: 1.9.3-p362
  users:
   - linguini

roles:
  - platform
  - rails

recipes:
  - mysql::server
  - iptables

server:
  host: 33.33.33.20
  platform: ubuntu
  password: vagrant
```

Gusteau only needs a node definition to run, but you'll need a few cookbooks to actually cook something :)
The following command generates an example configuration to get you started:

```
gusteau generate project-name
```

Next, `cd project-name` and see `nodes/example.yml`.


Provisioning a server
----------

The following command will run all roles and recipes from node's YAML file.

```
gusteau node-name provision
```

Use the `--bootstrap` or `-b` flag to bootstrap chef-solo (for the first time run).

Running recipes
-----------
You may choose to run a few recipes instead of full provisioning.

```
gusteau node-name run redis::server ntp unicorn
```

Using with Vagrant
------------------
At the moment Gusteau doesn't come with Vagrant integration. However, using it with Vagrant is easy, just make sure that you provide the correct IP address of the VM in node's YAML file.

```
vagrant up
gusteau node-name provision
```

Notes
-----

* Feel free to contribute a [bootstrap script](https://github.com/locomote/gusteau/tree/master/bootstrap) for your platform.
* Gusteau uploads  both `./cookbooks` and `./site-cookbooks` so that you can use [librarian-chef](https://github.com/applicationsonline/librarian) to include third party cookbooks.

