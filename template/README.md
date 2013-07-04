# chef-repo

Welcome to your example Chef-Repo, <%= @login %>.

Now that you've installed everything, let's have a look around.

## Structure

### `.gusteau.yml`

A configuration file for all your environments and nodes. This project features one environment, `example` which only includes one node, `box`.

### Vagrantfile

A configuration file for Vagrant which includes gusteau as a plugin. It detects all your `.gusteau.yml` nodes with `vagrant` keys in them and configures Vagrant instances for them. The `example-box` node is one such example.

### cookbooks

Gusteau uploads `site-cookbooks` and `cookbooks` directories when you converge a node. Between the two, `cookbooks` is a directory for your vendorized cookbooks. This example project uses Berkshelf, so in order to populate the directory run

```
berks install --path ./cookbooks
```

### site-cookbooks

Your repo-specific or work-in-progress cookbooks. A good place to store your [wrapper cookbooks](http://devopsanywhere.blogspot.com.au/2012/11/how-to-write-reusable-chef-cookbooks.html).

### data_bags

Chef Data bags. A way to store large pieces of domain-specifc configuration. See the included `users` data_bag for an example.

## Using gusteau

To try gusteau first with an example Vagrant node, bring it up:

```
vagrant up example-box
```

Then run `gusteau converge`:

```
gusteau converge example-box
```

## Testing your Chef-Repo

It is a very good practice to have tests for your Chef-driven infrastructure.
This project includes an example [test-kitchen](https://github.com/opscode/test-kitchen) setup to get you started.

The tests are implemented using the excellent [serverspec](http://serverspec.org/) framework.

There are two important bits to have a look at:

### test

The directory where integration tests are placed.

### `.kitchen.yml`

Test-kitchen configuration file where test platforms and suites are specified.

To run the tests:

```
bundle exec kitchen test
```

*Happy cooking with Chef and Gusteau!*
