require './spec/spec_helper'

describe Gusteau::Node do
  it "should raise if node yaml doesn't exist" do
    proc { Gusteau::Node.new('spec/nodes/void.yml') }.must_raise RuntimeError
  end

  describe "#dna" do
    let(:node) { Gusteau::Node.new('spec/nodes/example.yml') }

    let(:dna)  { node.send(:dna, type, arg, path) }
    let(:type) { nil }
    let(:arg)  { nil }
    let(:path) { '/tmp/testdna.json' }

    let(:json) { JSON::parse(File.read dna[:path]) }

    it "should create a new dna file" do
      File.exists?(dna[:path]).must_equal true
    end

    context "dna type not specified" do
      it "should contain a full run_list" do
        json['run_list'].must_equal ["role[redhat]", "recipe[rvm]", "recipe[rails::apps]"]
      end
    end

    context "dna type is :app" do
      let(:type) { :app }
      let(:arg)  { 'profile' }

      it "should only include apps recipe into run_list" do
        json['run_list'].must_equal ["recipe[apps]"]
      end

      it "should remove other apps entries from node config" do
        dna[:hash]['apps']['enabled'].must_equal [arg]
      end

      it "should return a hash with path key" do
        dna[:path].must_equal path
      end
    end

    context "dna type is :single" do
      let(:type) { :single }
      let(:arg)  { 'recipe[rvm]' }

      it "should only include the specified item into run_list" do
        json['run_list'].must_equal [arg]
      end
    end
  end
end
