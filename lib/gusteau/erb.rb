require 'erb'
require 'yaml'
require 'json'

module Gusteau
  module ERB
    def read_erb(path)
      ::ERB.new(File.read(path)).result binding
    end

    def read_erb_yaml(path)
      YAML::load(read_erb path)
    end
  end
end
