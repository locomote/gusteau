require './spec/spec_helper'

describe Gusteau::Node do
  it "should raise if node yaml doesn't exist" do
    proc { Gusteau::Node.new('spec/nodes/void.yml') }.must_raise RuntimeError
  end

  describe "#dna" do
    let(:node) { Gusteau::Node.new('spec/nodes/example.yml') }

    let(:dna)     { node.send(:dna, recipes) }
    let(:recipes) { [] }

    let(:path) { '/tmp/testdna.json' }
    let(:json) { JSON::parse(File.read dna[:path]) }

    it "should create a new dna file" do
      File.exists?(dna[:path]).must_equal true
    end

    context "recipes not specified" do
      it "should contain a full run_list" do
        json['run_list'].must_equal ["role[redhat]", "recipe[rvm]", "recipe[ntp]", "recipe[rails::apps]"]
      end
    end

    context "recipes specified" do
      let(:recipes)  { ['rvm', 'rails::apps'] }

      it "should only include the specified item into run_list" do
        json['run_list'].must_equal ["recipe[rvm]", "recipe[rails::apps]"]
      end
    end
  end
end
