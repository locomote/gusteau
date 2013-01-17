Gusteau
=======

*"Anyone can cook."*

[![Build Status](https://magnum.travis-ci.com/locomote/gusteau.png?token=sLrGziB4HXtaF5mwnaxi)](http://magnum.travis-ci.com/locomote/gusteau)

Introduction
------------

Gusteau is here to make servers provisioning easy and enjoyable.
It's a Chef Solo wrapper that manages configuration and lets you provision servers or just run arbitrary recipes on them.

Gettings started
----------------

The first thing to do is to generate a project:

```
gusteau generate project-name
```

Next, see `nodes/example.yml` for an example server configuration:

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

Provisioning a server
----------

The following command will run all roles and recipes from node's YML file.

```
gusteau node-name provision
```

Running recipes
-----------
You may choose to run a few recipes instead of full provisioning.

```
gusteau node-name run redis::server ntp unicorn
```

Notes
-----

* `--bootstrap` only works with Ubuntu, CentOS, RHEL and Gentoo Linux flavors. Feel free to contribute a [bootstrap script](https://github.com/locomote/gusteau/tree/master/bootstrap) for your platform!
* We encourage you to use [librarian-chef](https://github.com/applicationsonline/librarian) - a great way to bundle third-party cookbooks.

