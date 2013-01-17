require 'net/ssh'
require 'gusteau/compressed_tar_stream'
require 'gusteau/log'

module Gusteau
  module SSH
    include Gusteau::CompressedTarStream

    def ssh
      @ssh ||= begin
        opts = { :port => port }
        opts.update(:password => password) if @password
        log "#setting up ssh connection #{@user}@#{host}, #{opts.inspect})" do
          Net::SSH.start(host, @user, opts)
        end
      end
    end

    def send_command(cmd)
      exit_code = -1
      ssh.open_channel do |ch|
        ch.exec(prepared_cmd cmd) do |_, success|
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
        ch.exec(prepared_cmd "tar zxf - -C #{dest_dir}")
        ch.send_data(compressed_tar_stream(files))
        ch.eof!
      }.wait
    end

    private

    def prepared_cmd(cmd)
      user == 'root' ? cmd : "sudo -- sh -c '#{cmd}'"
    end
  end
end
