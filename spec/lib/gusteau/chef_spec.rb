require './spec/spec_helper.rb'

describe Gusteau::Chef do
  let(:platform)  { 'centos' }
  let(:server)    { Gusteau::Server.new('host' => 'example.com', 'platform' => platform) }
  let(:chef)      { Gusteau::Chef.new(server, platform) }

  describe "#run" do
    def expects_run_chef_solo
      server.expects(:run).with { |p1| p1 =~ /chef-solo/ }
    end

    before do
      server.expects(:upload).with { |p1, p2| p1.include? './cookbooks' }
      server.expects(:run).times(2)
    end

    context "bootstrap option is not specified" do
      it "should run chef solo" do
        expects_run_chef_solo
        chef.run(false, { :path => '/tmp/node.json' })
      end
    end

    context "bootstrap option is specified" do
      it "should run the bootstrap script and chef solo" do
        server.expects(:run).with('sh /etc/chef/bootstrap/centos.sh')
        expects_run_chef_solo
        chef.run(true, { :path => '/tmp/node.json' })
      end
    end
  end
end
