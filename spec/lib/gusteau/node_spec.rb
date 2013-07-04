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

  let(:node) do
    config = {
      'run_list' => [ "recipe[zsh]", "recipe[git]" ],
      'server' => { 'host' => 'example.com' }
    }
    Gusteau::Node.new 'test', config
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
      node.server.chef.expects(:run).with({}, dna)
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
      node.server.chef.expects(:run).with({}, dna)
      node.apply([ "recipe[nagios]", "role[base]" ], {})
    end
  end

  describe "#ssh" do
    it "should call server.ssh" do
      node.server.expects(:ssh)
      node.ssh
    end
  end
end
