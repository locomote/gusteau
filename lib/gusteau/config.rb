require 'gusteau/erb'
require 'gusteau/helpers'

module Gusteau
  class Config
    DEFAULT_CHEF_VERSION = '11.4.4'
    DEFAULT_CHEF_CONFIG_DIRECTORY = '/etc/chef'

    include Gusteau::ERB

    def self.read(config_path)
      @instance = Gusteau::Config.new(config_path)
    end

    def self.nodes
      @instance.send(:nodes)
    end

    def self.settings
      @instance.send(:settings)
    end

    def initialize(config_path)
      @config = if File.exists?(config_path)
        read_erb_yaml(config_path)
      else
        abort ".gusteau.yml not found"
      end
    end

    private

    def nodes
      env_config = @config['environments']

      @nodes ||= env_config.inject({}) do |nodes, (env_name, env_hash)|
        if env_hash['nodes']
          env_hash['nodes'].each_pair do |node_name, node_hash|
            node_name = "#{env_name}-#{node_name}"
            nodes[node_name] = build_node(node_name, env_hash, node_hash)
          end
        end
        nodes
      end
    end

    def settings
      {
        'cookbooks_path'  => @config['cookbooks_path'] || ['cookbooks', 'site-cookbooks'],
        'roles_path'      => @config['roles_path'] || 'roles',
        'bootstrap'       => @config['bootstrap'],
        'chef_version'    => @config['chef_version'] || DEFAULT_CHEF_VERSION,
        'chef_config_dir' => @config['chef_config_dir'] || DEFAULT_CHEF_CONFIG_DIRECTORY
      }
    end

    #
    # Node attributes get deep-merged with the environment ones
    # Node run_list overrides the environment one
    # Environment before hooks override global ones
    #
    def build_node(node_name, env_hash, node_hash)
      node_config = {
        'server'     => node_hash.slice('host', 'port', 'user', 'password', 'platform', 'vagrant'),
        'attributes' => (node_hash['attributes'] || {}).deep_merge(env_hash['attributes'] || {}),
        'run_list'   => node_hash['run_list']   || env_hash['run_list'],
        'before'     => env_hash['before']      || @config['before'],
        'after'      => env_hash['after']       || @config['after']
      }
      node_config['server'].delete 'attributes'
      Gusteau::Node.new(node_name, node_config)
    end
  end
end
