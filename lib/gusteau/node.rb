require 'gusteau/server'
require 'tmpdir'

module Gusteau
  class Node
    include Gusteau::Log

    attr_reader :name, :config, :server

    def initialize(node_name, node_config)
      @name   = node_name
      @config = node_config

      @server = Server.new(@config['server'])
      @dna_path = "#{Dir::tmpdir}/dna.json"
    end

    def to_s
      "#{name} (#{@server})"
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
        Kernel.system({ 'GUSTEAU_NODE' => name }, cmd)
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
