require './spec/spec_helper.rb'

describe Gusteau::Chef do
  before { Gusteau::Config.read('./spec/config/emile.yml') }

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
      server.expects(:run)
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
        server.expects(:run).with('sh /etc/chef/bootstrap.sh 10.26.0')
        expects_run_chef_solo
        chef.run({ :path => '/tmp/node.json' }, opts)
      end
    end
  end

  describe "#files_list" do
    subject { chef.send(:files_list, '/some/dna.json') }

    it "should produce a files paths hash" do
      subject['/some/dna.json'].must_equal     'dna.json'
      subject['private-cookbooks'].must_equal  'cookbooks-0'
      subject['basic-roles'].must_equal        'roles'
      subject['./bootstrap/osx.sh'].must_equal 'bootstrap.sh'
    end
  end
end
