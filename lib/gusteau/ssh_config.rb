require 'yaml'
require 'gusteau/server'

module Gusteau
  class SSHConfig
    def initialize(root_dir = ".")
      @config = []

      Dir.glob("#{root_dir}/nodes/**/*.yml").sort.each do |n|
        name   = File.basename(n, '.*')
        config = YAML::load_file(n)

        if server = config['server']
          @config << section(name, Gusteau::Server.new(server))
        end
      end
    end

    def section(name, server)
      <<-eos
Host #{name}
  HostName #{server.host}
  Port #{server.port}
  User #{server.user}
      eos
    end

    def to_s
      <<-eos
# BEGIN GUSTEAU NODES

#{@config.join("\n")}
# END GUSTEAU NODES
      eos
    end
  end
end
