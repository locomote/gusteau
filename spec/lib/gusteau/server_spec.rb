require './spec/spec_helper.rb'

describe Gusteau::Server do
  let(:config) do
    {
      'host'     => 'demo.com',
      'port'     => '2222',
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

  describe "Server password" do
    subject { server.password }

    context "vagrant option is not present" do
      it { subject.must_be_nil }
    end

    context "vagrant option is set to true" do
      let(:config) do
      {
        'host'     => 'demo.com',
        'port'     => '2222',
        'platform' => 'ubuntu',
        'vagrant'  =>  true
      }
      end
      it { subject.must_equal 'vagrant' }
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
end
