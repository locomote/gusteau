require 'yaml'
require 'gusteau/server'

module Gusteau
  class SSHConfig
    def initialize(root_dir = ".")
      @config = Dir.glob("#{root_dir}/nodes/**/*.yml").map do |n|
        name   = File.basename(n, '.*')
        config = YAML::load_file(n)['server']

        section name, Gusteau::Server.new(config)
      end.join("\n")
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

#{@config}
# END GUSTEAU NODES
      eos
    end
  end
end
