require 'gusteau/server'
require 'gusteau/chef'

module Gusteau
  class Node
    include Gusteau::Log

    attr_reader :name, :config, :server

    def initialize(name, config)
      @name   = name
      @config = config

      @server = Server.new(@config['server']) if @config['server']
      @dna_path = '/tmp/dna.json'
    end

    def converge(opts = {})
      with_hooks do
        server.chef.run dna, opts
      end
    end

    def apply(run_list, opts = {})
      with_hooks do
        server.chef.run dna(run_list), opts
      end
    end

    def ssh
      server.ssh
    end

    private

    def with_hooks(&block)
      hook 'before'
      yield
      hook 'after'
    end

    def hook(hook_type)
      (@config[hook_type] || []).each do |cmd|
        Kernel.system cmd
        unless $?.exitstatus == 0
          log_error "Error executing a #{hook_type} hook: '#{cmd}'"
          exit 1
        end
      end
    end

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
