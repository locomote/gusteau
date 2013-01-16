require 'gusteau/log'
require 'gusteau/ssh'
require 'gusteau/rsync'

module Gusteau
  class Server
    include Gusteau::Log
    include Gusteau::SSH
    include Gusteau::Rsync

    attr_reader :host, :port, :user, :password, :chef

    def initialize(config, opts={})
      @host     = config['host']
      @port     = (config['port'] || '22').to_i
      @user     = config['user'] || 'root'
      @password = config['password']
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
        log("%{host}> #{prepared_cmd cmd}", :host => host) do
          unless send_command(cmd)
            log_error("%{host}> #{prepared_cmd cmd}", :host => host)
            raise
          end
        end
      end
      true
    end
  end
end
