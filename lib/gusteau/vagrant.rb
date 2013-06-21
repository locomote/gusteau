module Gusteau
  module Vagrant
    extend self

    def complete_defaults(d)
      d[:ip]     ||= '33.33.33.99'
      d[:memory] ||= 1024
      d[:cpus]   ||= 1
      d
    end

    def vagrant_config(config_path, defaults, label)
      if config = YAML::load_file(config_path)['vagrant']
        name  = File.basename(config_path, '.yml')
        label = label.nil? ? name : "#{label}-#{name}"

        box_url = config.fetch 'box_url' do
          raise "Box url can't be determined for #{name}" unless defaults[:box_url]
          defaults[:box_url]
        end

        defaults = complete_defaults(defaults)
        {
          :name    => name,
          :label   => label,
          :box_url => box_url,
          :ip      => config.fetch('IP',      defaults[:ip]),
          :cpus    => config.fetch('cpus',    defaults[:cpus]),
          :memory  => config.fetch('memory',  defaults[:memory])
        }
      end
    end

    def define_vm(c, config)
      c.vm.define config[:name] do |instance|
        instance.vm.box     = config[:name]
        instance.vm.box_url = config[:box_url]

        instance.vm.provider :virtualbox do |vb|
          vb.customize ['modifyvm', :id,
            '--memory', config[:memory],
            '--name',   config[:label],
            '--cpus',   config[:cpus],
            '--natdnsproxy1', 'on'
          ]
        end
        instance.vm.network :private_network, :ip => config[:ip]
      end
    end

    def define_nodes(c, defaults = {}, label = nil)
      Dir.glob("./nodes/**/*.yml").sort.each do |path|
        if config = vagrant_config(path, defaults, label)
          define_vm c, config
        end
      end
    end

  end
end
