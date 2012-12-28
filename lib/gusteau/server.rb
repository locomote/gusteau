require 'gusteau/log'
require 'gusteau/ssh'

module Gusteau
  class Server
    include Gusteau::Log
    include Gusteau::SSH

    attr_reader :host, :port, :password, :chef

    def initialize(config, opts={})
      @host = config['host']
      @port = (config['port'] || '22').to_i
      @password = 'vagrant' if config['vagrant']
      @chef = Gusteau::Chef.new(self, config['platform'])
    end

    def upload(files_and_dirs, dest_dir)
      log "#uploading #{files_and_dirs.join(' ')} to #{@host}:#{dest_dir}" do
        files = Find.find(*files_and_dirs).to_a
        send_files(files, dest_dir)
      end
    end

    def run(*cmds)
      cmds.each do |cmd|
        log("%{host}> #{cmd}", host: host) do
          unless send_command(cmd)
            log_error("%{host}> #{cmd}", host: host)
            raise
          end
        end
      end
      true
    end
  end
end
