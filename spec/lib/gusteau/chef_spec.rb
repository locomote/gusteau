require './spec/spec_helper.rb'

describe Gusteau::Chef do
  let(:platform)  { 'centos' }
  let(:server)    { Gusteau::Server.new('host' => 'example.com', 'platform' => platform) }
  let(:chef)      { Gusteau::Chef.new(server, platform) }

  describe "#run" do
    let(:bootstrap) { false }
    let(:opts)      { { 'bootstrap' => bootstrap, 'why-run' => false } }

    def expects_run_chef_solo
      server.expects(:run).with { |p1| p1 =~ /chef-solo/ }
    end

    before do
      server.expects(:upload)
      server.expects(:run).times(2)
    end

    context "bootstrap option is not specified" do
      it "should run chef solo" do
        expects_run_chef_solo
        chef.run({ :path => '/tmp/node.json' }, opts)
      end
    end

    context "bootstrap option is specified" do
      let(:bootstrap) { true }

      it "should run the bootstrap script and chef solo" do
        server.expects(:run).with('sh /etc/chef/bootstrap/centos.sh')
        expects_run_chef_solo
        chef.run({ :path => '/tmp/node.json' }, opts)
      end
    end
  end
end
