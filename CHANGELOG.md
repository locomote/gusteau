## 1.0.7.dev / 2013-07-10
* Replace the fully-blown test-kitchen with a simpler serverspec setup
* Randomise Vagrant IP address in the template
* Add timestamp to generated vm names in the template to avoid naming conflicts

## 1.0.6.dev / 2013-07-09
* Bugfix: Ruby 1.8.7 and Rubinius compatibility
* Highlight node yaml with Coderay in `gusteau show`.

## 1.0.5.dev / 2013-07-09
* Bugfix: `cookbooks_path` was not working properly
* Add an ability to specify a custom bootstrap script
* Streamline file uploading logic in `chef.rb`

## 1.0.4.dev / 2013-07-08
* Bugfix: `after` hook was not taking effect
* Add a quick `show nodename` subcommand for printing out individual node configuration
* Add an ability to configure `cookbooks_path` and `roles_path` from within `.gusteau.yml`
## 1.0.3.dev / 2013-07-07
* Implement `before` and `after` hooks (global and environment-based)

## 1.0.2.dev / 2013-07-06
* Fix Ruby 1.8.7 and Rubinius compatibility

## 1.0.1.dev / 2013-07-05
* Fix the project generator bug
* Make project generator output look nicer

## 1.0.0.dev / 2013-07-04
* Use the unified `.gusteau.yml` configuration file for all nodes and environments
* Support more advanced configuration (multiple nodes per environment)
* Provide 100% test coverage
* Use omnibus installation if platform is unspecified
* Update the template to include a test-kitchen setup with serverspec tests

