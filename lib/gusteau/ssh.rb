require 'net/ssh'
require 'gusteau/tgz_stream'
require 'gusteau/log'

module Gusteau
  module SSH
    include Gusteau::TgzStream

    def ssh
      @ssh ||= begin
        user = 'root'
        opts = { :port => port }
        opts.update(:password => password) if password
        log "#setting up ssh connection #{user}@#{host}, #{opts.inspect})" do
          Net::SSH.start(host, user, opts)
        end
      end
    end

    def send_command(cmd)
      exit_code = -1
      ssh.open_channel do |ch|
        ch.exec([cmd].flatten.join("\n")) do |_, success|
          if success
            ch.on_data { |_,data| puts data }
            ch.on_extended_data { |_,_,data| $stderr.puts data }
            ch.on_request("exit-status") { |_,data| exit_code = data.read_long }
          else
            raise "FAILED to execute command: #{cmd.inspect}"
          end
        end
      end
      ssh.loop
      exit_code == 0
    end

    def send_files(files, dest_dir)
      ssh.open_channel { |ch|
        ch.exec("tar zxf - -C #{dest_dir}")
        ch.send_data(tgz_stream(files))
        ch.eof!
      }.wait
    end
  end
end
