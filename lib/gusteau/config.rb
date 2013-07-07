require 'gusteau/erb'
require 'hash_deep_merge'

module Gusteau
  module Config
    extend self
    extend Gusteau::ERB

    def nodes(config_path)
      if File.exists?(config_path)
        config = read_erb_yaml(config_path)
        env_config = config['environments']

        env_config.inject({}) do |nodes, (env_name, env_hash)|
          if env_hash['nodes']
            env_hash['nodes'].each_pair do |node_name, node_hash|
              node_name = "#{env_name}-#{node_name}"
              nodes[node_name] = build_node(config, node_name, env_hash, node_hash)
            end
          end
          nodes
        end
      else
        abort ".gusteau.yml not found"
      end
    end

    #
    # Node attributes get deep-merged with the environment ones
    # Node run_list overrides the environment one
    # Environment before hooks override global ones
    #
    def build_node(config, node_name, env_hash, node_hash)
      config = {
        'server'     => node_hash,
        'attributes' => (env_hash['attributes'] || {}).deep_merge(node_hash['attributes'] || {}),
        'run_list'   => node_hash['run_list'] || env_hash['run_list'],
        'before'     => env_hash['before'] || config['before']
      }
      Gusteau::Node.new(node_name, config)
    end
  end
end
