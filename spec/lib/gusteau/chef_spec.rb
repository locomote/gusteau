require './spec/spec_helper.rb'

describe Gusteau::Chef do
  let(:platform) { 'centos' }
  let(:server)   { MiniTest::Mock.new }
  let(:chef)     { Gusteau::Chef.new(server, platform) }

  describe "#run" do
    it "should upload dna, cookbooks, roles and data_bags" do
      server.expect(:upload, nil, [%W(/tmp/node.json ./bootstrap ./cookbooks ./site-cookbooks ./roles ./data_bags), "/etc/chef"])
      server.expect(:run, nil, ["rm -rf /{etc,tmp}/chef && mkdir /{etc,tmp}/chef"])
      server.expect(:run, nil, [String])

      chef.run(false, { :path => '/tmp/node.json' })
      server.verify
    end
  end
end
