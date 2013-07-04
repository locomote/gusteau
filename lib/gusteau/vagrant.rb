require 'hashie'
require 'gusteau'

class Hash; include Hashie::Extensions::SymbolizeKeys; end

module Gusteau
  module Vagrant
    extend self
    extend Gusteau::Log

    def detect(config)
      options = Hashie::Mash.new
      options.defaults = Hashie::Mash.new

      yield options if block_given?
      define_nodes(config, options.to_hash.symbolize_keys)
    end

    def define_nodes(config, options, prefix = nil)
      Gusteau::Config.nodes(options[:config_path] || ".gusteau.yml").each_pair do |name, node|
        if node.config['server']['vagrant']
          define_vm config, node, options
        end
      end
    end

    def vm_config(node, options)
      defaults = options[:defaults] || {}
      config   = node.config['server']['vagrant']
      label    = options[:prefix] ? "#{options[:prefix]}-#{node.name}" : node.name

      config = {} if config == true

      box_url = config.fetch 'box_url' do
        unless defaults[:box_url]
          raise "Box url can't be determined for #{node.name}"
        end
        defaults[:box_url]
      end

      {
        :name    => node.name,
        :label   => label,
        :box_url => box_url,
        :ip      => config['IP']     || defaults[:ip],
        :cpus    => config['cpus']   || defaults[:cpus]   || 1,
        :memory  => config['memory'] || defaults[:memory] || 1024
      }
    end

    def define_vm(config, node, options)
      vm_config = vm_config(node, options)

      config.vm.define vm_config[:name] do |instance|
        instance.vm.box     = vm_config[:name]
        instance.vm.box_url = vm_config[:box_url]

        instance.vm.provider :virtualbox do |vb|
          vb.customize ['modifyvm', :id,
            '--memory', vm_config[:memory],
            '--name',   vm_config[:label],
            '--cpus',   vm_config[:cpus],
            '--natdnsproxy1', 'on'
          ]
        end

        if vm_config[:ip]
          instance.vm.network :private_network, :ip => vm_config[:ip]
        end

        define_provisioner(instance, node) if options[:provision]
      end
    end

    def define_provisioner(instance, node)
      instance.vm.provision 'chef_solo' do |chef|
        chef.data_bags_path = 'data_bags'
        chef.cookbooks_path = ['cookbooks', 'site-cookbooks']
        chef.roles_path     = 'roles'
        chef.json     = node.config['attributes'] || {}
        chef.run_list = node.config['run_list'] || []
      end
    end
  end
end

