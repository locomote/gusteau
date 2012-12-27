require 'yaml'
require 'json'

module Gusteau
  class Node
    attr_reader :server

    def initialize(path)
      raise "Node YAML file #{path} not found" unless path && File.exists?(path)

      @name   = File.basename(path).gsub('.yml','')
      @config = YAML::load_file path
      @dna_path = '/tmp/dna.json'

      @server = Server.new(@config['server'])
    end

    def provision(bootstrap = false)
      @server.chef.run bootstrap, dna(true)
    end

    def run(bootstrap = false, recipes)
      @server.chef.run bootstrap, dna(false, recipes)
    end

    private

    def dna(include_all, recipes = [])
      node_dna = {
        :path => @dna_path,
        :hash => {
          :instance_role => @name,
          :run_list      => run_list(include_all, recipes)
        }.merge(@config['json'])
      }

      File.open(node_dna[:path], 'w+') { |f| f.puts node_dna[:hash].to_json }
      node_dna
    end

    def run_list(include_all, recipes)
      if include_all
        list = []
        list += @config['roles'].map   { |r| "role[#{r}]"   } if @config['roles']
        list += @config['recipes'].map { |r| "recipe[#{r}]" } if @config['recipes']
        list
      else
        recipes.map { |r| "recipe[#{r}]" }
      end
    end
  end
end
