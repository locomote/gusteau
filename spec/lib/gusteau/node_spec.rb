require './spec/spec_helper'

describe Gusteau::Node do
  it "should raise if node yaml doesn't exist" do
    proc { Gusteau::Node.new('spec/nodes/void.yml') }.must_raise RuntimeError
  end

  describe "#dna" do
    let(:node) { Gusteau::Node.new('spec/nodes/production.yml') }

    let(:dna)         { node.send(:dna, include_all, recipes) }
    let(:include_all) { true }
    let(:recipes)     { [] }

    let(:path) { '/tmp/testdna.json' }
    let(:json) { JSON::parse(File.read dna[:path]) }

    it "should create a new dna file" do
      File.exists?(dna[:path]).must_equal true
    end

    it "should support ERB" do
      json['environment'].must_equal "production"
    end

    context "recipes not specified" do
      it "should contain a full run_list" do
        json['run_list'].must_equal ["role[redhat]", "recipe[rvm]", "recipe[ntp]", "recipe[rails::apps]"]
      end
    end

    context "recipes specified" do
      let(:include_all) { false }
      let(:recipes)     { ['rvm', 'rails::apps'] }

      it "should only include the specified item into run_list" do
        json['run_list'].must_equal ["recipe[rvm]", "recipe[rails::apps]"]
      end
    end
  end

  describe "#vagrant_wrap" do
    let(:node) { Gusteau::Node.new('spec/nodes/development.yml') }

    describe "#ssh" do
      context "server is defined" do
        it "should call server.ssh" do
          node.server.expects(:ssh)
          node.ssh
        end
      end

      context "vagrant is defined, server is not" do
        before do
          node.stubs(:server).returns(nil)
        end

        it "should call 'vagrant ssh'" do
          Kernel.expects(:system).with("vagrant ssh development")
          Kernel.expects(:exit)
          node.ssh
        end
      end

      context "neither server nor vagrant are defined" do
        before do
          node.stubs(:server).returns(nil)
          node.config['vagrant'] = nil
        end

        it "should exit with an error" do
          Kernel.expects(:abort)
          node.ssh
        end
      end
    end

    describe "#run" do
      context "server is defined" do
        it "should call server.chef.run" do
          chef = mock()
          node.server.expects(:chef).returns(chef)
          chef.expects(:run)

          node.run('test')
        end
      end

      context "vagrant is defined, server is not" do
        before do
          node.stubs(:server).returns(nil)
        end

        it "should exit with an error" do
          Kernel.expects(:abort).with("'run' is not supported for vagrant-only nodes. Please configure 'server' for development node")
          node.run('test')
        end
      end

    end
  end
end
