require 'gusteau/server'
require 'gusteau/chef'

module Gusteau
  class Node
    attr_reader :name, :config, :server

    def initialize(name, config)
      @name   = name
      @config = config

      @server = Server.new(@config['server']) if @config['server']
      @dna_path = '/tmp/dna.json'
    end

    def converge(opts = {})
      server.chef.run opts, dna
    end

    def apply(opts = {}, run_list)
      server.chef.run opts, dna(run_list)
    end

    def ssh
      server.ssh
    end

    private

    def dna(run_list = nil)
      node_dna = {
        :path => @dna_path,
        :hash => {
          :instance_role => @name,
          :run_list      => run_list || @config['run_list']
        }.merge(@config['attributes'] || {})
      }

      File.open(node_dna[:path], 'w+') { |f| f.puts node_dna[:hash].to_json }
      node_dna
    end
  end
end
