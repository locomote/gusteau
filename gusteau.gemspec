# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gusteau/version'

Gem::Specification.new do |gem|
  gem.name          = "gusteau"
  gem.version       = Gusteau::VERSION
  gem.authors       = ["Vasily Mikhaylichenko", "Chris"]
  gem.email         = ["vasily@locomote.com", "chris@locomote.com"]
  gem.description   = %q{A fine Chef Solo wrapper}
  gem.summary       = %q{Making servers provisioning enjoyable since 2013.}
  gem.homepage      = "http://gusteau.gs"

  gem.files         = `git ls-files | grep -vE '(jenkins|.gitmodules|.ruby-version)'`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'optitron'
  gem.add_dependency 'inform'
  gem.add_dependency 'json'
  gem.add_dependency 'hashie'
  gem.add_dependency 'hash-deep-merge'
  gem.add_dependency 'net-ssh', '>= 2.2.2'
  gem.add_dependency 'archive-tar-minitar', '>= 0.5.2'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'cane'
end
