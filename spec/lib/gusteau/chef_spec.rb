require './spec/spec_helper.rb'

describe Gusteau::Chef do
  let(:platform) { 'centos' }
  let(:server)   { MiniTest::Mock.new }
  let(:chef)     { Gusteau::Chef.new(server, platform) }

  describe "#bootstrap" do
    context "platform bootstrap script is not present" do
      let(:platform) { 'archlinux' }

      it "should raise" do
        proc { chef.bootstrap }.must_raise RuntimeError
      end
    end
  end

  describe "#run" do
    it "should upload dna, cookbooks, roles and data_bags" do
      server.expect(:upload, nil, [%W(/tmp/node.json ./cookbooks ./site-cookbooks ./roles ./data_bags), "/etc/chef"])
      server.expect(:run, nil, [String])

      chef.run({ :path => '/tmp/node.json' })
      server.verify
    end
  end
end
