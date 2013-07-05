require 'yaml'
require 'gusteau/server'

module Gusteau
  class SSHConfig
    def initialize(nodes)
      @config = []

      nodes.sort.each do |name, node|
        if server = node.server
          @config << section(name, server)
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
