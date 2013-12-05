require './spec/spec_helper'

describe Gusteau::Node do

  describe "#initialize" do
    let(:node) do
      Gusteau::Node.new 'test', { 'server' => { 'host' => 'example.com' } }
    end

    it "should create a server attribute" do
      node.server.host.must_equal 'example.com'
    end
  end

  let(:before_hooks) { ['bundle', 'vagrant up'] }

  let(:node) do
    config = {
      'run_list' => [ "recipe[zsh]", "recipe[git]" ],
      'server' => { 'host' => 'example.com' },
      'before' => before_hooks
    }
    Gusteau::Node.new 'test', config
  end

  describe "provisioning" do
    before do
      node.expects(:hook).once.with 'before'
      node.expects(:hook).once.with 'after'
    end

    describe "#converge" do
      it "should run chef with the full run_list" do
        dna = {
          :path => '/tmp/dna.json',
          :hash => {
            :instance_role => 'test',
            :run_list => ['recipe[zsh]', 'recipe[git]']
          }
        }
        node.server.chef.expects(:run).with(dna, {})
        node.converge
      end
    end

    describe "#apply" do
      it "should run chef with the specific run_list" do
        dna = {
          :path => '/tmp/dna.json',
          :hash => {
            :instance_role => 'test',
            :run_list => ['recipe[nagios]', 'role[base]']
          }
        }
        node.server.chef.expects(:run).with(dna, {})
        node.apply([ "recipe[nagios]", "role[base]" ], {})
      end
    end
  end

  describe "#ssh" do
    it "should call server.ssh" do
      node.server.expects(:ssh)
      node.ssh
    end
  end

  describe "#hook" do
    it "should execute system commands" do
      Kernel.expects(:system).with({'GUSTEAU_NODE' => 'test'}, 'bundle')
      Kernel.expects(:system).with({'GUSTEAU_NODE' => 'test'}, 'vagrant up')
      node.server.chef.expects(:run)
      node.apply([], {})
    end

    context "command doesn't succeed" do
      let(:before_hooks) { %w{ohwhatthehellerror} }

      it "should exit with error" do
        proc { node.apply([], {}) }.must_raise SystemExit
      end
    end
  end

  describe "#to_s" do
    it "returns a node name and an SSH connection string" do
      node.to_s.must_equal 'test (root@example.com)'
    end
  end
end
