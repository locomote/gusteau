require './spec/spec_helper.rb'

describe Gusteau::Chef do
  let(:platform)  { 'centos' }
  let(:server)    { Gusteau::Server.new('host' => 'example.com', 'platform' => platform) }
  let(:dest_dir)  { :a_dest_dir }
  let(:chef)      { Gusteau::Chef.new(server, platform, dest_dir) }

  describe "#run" do
    let(:bootstrap) { false }
    let(:opts)      { { 'bootstrap' => bootstrap, 'why-run' => false } }

    def expects_sync_files
      server.expects(:sync_files).with { |p1, p2| p2 == dest_dir }
    end

    def expects_run_chef_solo
      server.expects(:run).with { |p1| p1 =~ /chef-solo/ }
    end

    context "bootstrap option is not specified" do
      it "should run chef solo" do
        expects_sync_files
        expects_run_chef_solo
        chef.run(opts, { :path => '/tmp/node.json' })
      end
    end

    context "bootstrap option is specified" do
      let(:bootstrap) { true }

      it "should run the bootstrap script and chef solo" do
        server.expects(:run).with('sh /etc/chef/bootstrap/centos.sh')
        expects_sync_files
        expects_run_chef_solo
        chef.run(opts, { :path => '/tmp/node.json' })
      end
    end
  end
end
