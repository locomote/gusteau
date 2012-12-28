# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gusteau/version'

Gem::Specification.new do |gem|
  gem.name          = "gusteau"
  gem.version       = Gusteau::VERSION
  gem.authors       = ["Vasily Mikhaylichenko", "Chris"]
  gem.email         = ["vasily@locomote.com", "chris@locomote.com"]
  gem.description   = %q{À la carte server provisioning}
  gem.summary       = %q{A flexible and fast Chef solo deployment tool}
  gem.homepage      = "http://github.com/locomote/gusteau"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'optitron'
  gem.add_dependency 'inform'
  gem.add_dependency 'net-ssh', '~> 2.2.2'
  gem.add_dependency 'archive-tar-minitar', '~> 0.5.2'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
end
