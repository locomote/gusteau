require 'zlib'
require 'archive/tar/minitar'
require 'stringio'

module Gusteau
  module CompressedTarStream
    private

    def compressed_tar_stream(files, opts={})
      using = opts[:using] || Zlib::GzipWriter
      log "#compressing #{files.size} files for upload (using #{using}): " do
        tar = Archive::Tar::Minitar::Output.new(using.new(StringIO.new('')))
        files.each do |f|
          print '.'
          Archive::Tar::Minitar.pack_file(f, tar)
        end
        tar.close.string.force_encoding('ASCII-8BIT')
        .tap { |data| puts " (compressed down to #{data.size} bytes)" }
      end
    end
  end
end
