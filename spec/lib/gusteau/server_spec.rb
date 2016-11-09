require './spec/spec_helper.rb'

describe Gusteau::Server do
  let(:config) do
    {
      'host'     => 'demo.com',
      'port'     => 2222,
      'platform' => 'ubuntu'
    }
  end

  let(:server) { Gusteau::Server.new(config) }

  before do
    def server.log(msg, opts={})
      yield if block_given?
    end

    def server.log_error(msg, opts={})
    end
  end

  describe "Default user" do
    subject { server.user }

    context "User not specified in node config" do
      it { subject.must_equal 'root' }
    end

    context "User specified in node config" do
      let(:config) do
      {
        'host'     => 'demo.com',
        'port'     => 2222,
        'user'     => 'oneiric',
        'platform' => 'ubuntu',
      }
      end
      it { subject.must_equal 'oneiric' }
    end
  end

  describe "#run" do
    it "should raise if one of the commands fails" do
      server.stub(:send_command, false) do
        proc { server.run('failure') }.must_raise RuntimeError
      end
    end

    it "should return true if all command succeed" do
      server.stub(:send_command, true) do
        server.run('uname').must_equal true
      end
    end
  end

  describe "#upload" do
    let(:pr) { "/tmp/gusteau-test" }

    before { ["#{pr}/cookbooks", "#{pr}/.git"].each { |d| FileUtils.mkdir_p(d) } }
    after  { FileUtils.rm_rf(pr) }

    it "skips the excluded files" do
      server.expects(:send_files).with(["#{pr}/cookbooks"], "/etc/chef", nil)
      server.upload(["#{pr}/cookbooks", "#{pr}/.git"], "/etc/chef", { :exclude => "#{pr}/.git" })
    end
  end

  describe "#prepared_cmd" do
    subject { server.send(:prepared_cmd, 'cd /etc/chef && touch test') }

    context "user is root" do
      it { subject.must_equal "sh -l -c 'cd /etc/chef && touch test'" }
    end

    context "user is not root" do
      before { server.stubs(:user).returns('vaskas') }
      it     { subject.must_equal "sudo -- sh -l -c 'cd /etc/chef && touch test'" }
    end
  end

  describe "#ssh" do
    it "should call gusteau_ssh_expect with connection arguments" do
      Kernel.expects(:system).with { |arg| arg =~ /gusteau_ssh_expect root@demo.com 2222/ }
      server.ssh
    end
  end

  describe "#to_s" do
    it "returns an SSH connection string" do
      server.to_s.must_equal 'root@demo.com -p 2222'
    end

    describe "with port 22" do
      let(:config) do
        {
          'host'     => 'demo.com',
          'port'     => 22,
          'platform' => 'ubuntu'
        }
      end

      it "skips -p" do
        server.to_s.must_equal "root@demo.com"
      end
    end

    describe "with jump setting" do
      let(:config) do
        {
          'host'     => 'demo.com',
          'port'     => 2222,
          'platform' => 'ubuntu',
          'jump'     => 'hoop'
        }
      end

      it "returns proxy command" do
        server.to_s.must_equal "-o ProxyCommand='ssh -W %h:%p hoop' root@demo.com -p 2222"
      end
    end
  end
end
