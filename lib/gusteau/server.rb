require 'gusteau/chef'
require 'gusteau/ssh'
require 'gusteau/log'

module Gusteau
  class Server
    include Gusteau::Log
    include Gusteau::SSH

    attr_reader :host, :port, :user, :password, :chef

    def initialize(config)
      @host     = config['host']
      @port     = config['port'] || 22
      @user     = config['user'] || 'root'
      @password = config['password']
      @chef     = Gusteau::Chef.new(self, config['platform'])
    end

    def to_s
      "#{user}@#{host}#{" -p #{port}" unless port == 22}"
    end

    def upload(files_and_dirs, dest_dir, opts={})
      log "#uploading #{files_and_dirs.join(' ')} to #{@host}:#{dest_dir}" do
        files = []
        Find.find(*files_and_dirs) do |f|
          files << f unless(opts[:exclude] && f.include?(opts[:exclude]))
        end
        send_files(files, dest_dir, opts[:strip_c])
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

    def ssh
      ssh_expect = File.expand_path("../../../bin/gusteau_ssh_expect", __FILE__)
      Kernel.system "#{ssh_expect} #{@user}@#{@host} #{@port} #{@password}"
    end
  end
end
