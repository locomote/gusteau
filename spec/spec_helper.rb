require 'coveralls'
require 'simplecov'

if ENV['COVERAGE'] == 'coveralls'
  Coveralls.wear!
else
  SimpleCov.start do
    add_filter "/spec/"
  end
end

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
require 'lib/gusteau'
require 'minitest/autorun'
require 'mocha/setup'

class MiniTest::Spec
  class << self
    alias :context :describe
  end
end
