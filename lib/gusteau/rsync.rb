# TODO - test if this works when src_files and dest_dir contain whitespace

module Gusteau
  module Rsync
    def sync_files(src_files, dest_dir, opts={})
      rsync_cmd = "rsync -#{opts[:rsync_opts] || "avzP"} #{src_files.join(' ')} #{user}@#{host}:#{dest_dir}"
      log "#syncing local chef source files to remote dir ..." do
        @password ? system_using_password(rsync_cmd , @password) : system(rsync_cmd)
      end
    end

    private

    def system_using_password(cmd, password)
      system %{
        expect -c '
          set timeout -1
          set send_human {.05 0.1 1 .07 1.5}
          eval spawn #{cmd}
          match_max 100000
          expect {
            -re " password: "
            { sleep 0.1 ; send -- "#{password}\r" ; sleep 0.3 }
          }
          interact
        '
      }
    end
  end
end
