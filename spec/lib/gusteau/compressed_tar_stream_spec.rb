require './spec/spec_helper'

describe Gusteau::CompressedTarStream do

  let(:compressor_class) do
    class Example
      include Gusteau::Log
      include Gusteau::CompressedTarStream
      attr_accessor :host, :port, :user, :password
    end
    Example
  end

  let(:compressor) { compressor_class.new }

  describe "#compressed_tar_stream" do
    let(:tp) { "/tmp/gusteau-spec-11" }

    before do
      FileUtils.mkdir_p(tp)
      %w{ a b c }.each { |l| FileUtils.touch("#{tp}/#{l}.rb") }
    end

    after { FileUtils.rm_rf(tp) }

    it "should compress the files" do
      res = compressor.send(:compressed_tar_stream, ["#{tp}/a.rb", "#{tp}/b.rb", "#{tp}/c.rb"])
      assert res.length > 0
    end
  end
end
