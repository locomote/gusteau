require 'zlib'
require 'archive/tar/minitar'
require 'stringio'

module Gusteau
  module TgzStream
    private

    def tgz_stream(files)
      log "#compressing files for upload: " do
        tar = Archive::Tar::Minitar::Output.new(Zlib::GzipWriter.new(StringIO.new('')))
        files.each do |f|
          print '.'
          Archive::Tar::Minitar.pack_file(f, tar)
        end
        puts
        tar.close.string.force_encoding('ASCII-8BIT')
      end
    end
  end
end
