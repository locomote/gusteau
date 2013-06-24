require 'gusteau/server'
require 'gusteau/chef'
require 'gusteau/erb'

module Gusteau
  class Node
    include Gusteau::ERB

    attr_reader :name, :config, :server

    def initialize(path)
      raise "Node YAML file #{path} not found" unless path && File.exists?(path)

      @name   = File.basename(path).gsub('.yml','')
      @config = read_erb_yaml(path)

      @server = Server.new(@config['server']) if @config['server']
      @dna_path = '/tmp/dna.json'
    end

    def provision(opts = {})
      wrap_vagrant :provision do
        server.chef.run opts, dna(true)
      end
    end

    def run(opts = {}, *recipes)
      wrap_vagrant :run do
        server.chef.run opts, dna(false, recipes.flatten)
      end
    end

    def ssh
      wrap_vagrant :ssh do
        server.ssh
      end
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

    def wrap_vagrant(method)
      if server
        yield
      elsif @config['vagrant']
        Vagrant.send(method, @name)
      else
        Kernel.abort "Neither 'server' nor 'vagrant' defined for #{@name}. Please provide one."
      end
    end
  end
end
