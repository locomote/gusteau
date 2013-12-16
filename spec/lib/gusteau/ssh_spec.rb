require './spec/spec_helper'

describe Gusteau::SSH do
  let(:connector_class) do
    class Example
      include Gusteau::SSH
      attr_accessor :host, :port, :user, :password
    end
    Example
  end

  let(:connector) { connector_class.new }

  describe "#conn" do
    before do
      connector.host = 'microsoft.com'
      connector.port = 2202
      connector.user = 'ray'
    end

    context "password is present" do
      it "should use SSH port and password when present" do
        connector.password = 'qwerty123'

        Net::SSH.expects(:start).with('microsoft.com', 'ray', {:port => 2202, :password => 'qwerty123'})
        connector.conn
      end
    end

    context "password is not present" do
      it "should not use password" do
        Net::SSH.expects(:start).with('microsoft.com', 'ray', {:port => 2202})
        connector.conn
      end
    end
  end

  describe "send methods" do
    let(:conn)    { stub_everything('conn') }
    let(:channel) { stub_everything('channel') }

    before do
      connector.expects(:conn).at_least_once.returns(conn)

      def conn.open_channel
        yield channel
        channel # is this the correct way to test it?
      end
      conn.expects(:channel).at_least_once.returns(channel)
    end

    describe "#send_command" do
      context "user is root" do
        before { connector.user = 'root' }

        it "should execute the command without sudo" do
          channel.expects(:exec).with("sh -l -c 'cowsay'")
          connector.send_command 'cowsay'
        end
      end

      context "user is not root" do
        before { connector.user = 'vaskas' }

        it "should execute the command with sudo" do
          channel.expects(:exec).with("sudo -- sh -l -c 'cowsay'")
          connector.send_command 'cowsay'
        end
      end

      describe "success status" do
        let(:success) { true }

        before do
          def channel.exec(cmd); yield true, success; end
          channel.expects(:success).returns(success)
        end

        context "command succeeded" do
          it "should start receiving data" do
            channel.expects(:on_data)
            connector.send_command 'sl'
          end
        end

        context "command failed" do
          let(:success) { false }

          it "should raise an exception" do
            proc { connector.send_command 'sl' }.must_raise RuntimeError
          end
        end
      end
    end

    describe "#send_files" do
      before do
        connector.user = 'root'
        connector.expects(:compressed_tar_stream).returns(mock())
        channel.expects(:send_data)
      end

      it "should execute the extraction command and send the data" do
        channel.expects(:exec).with("sh -l -c 'tar zxf - -C /etc/chef '")
        connector.send_files(%w{ a b }, '/etc/chef')
      end

      it "should strip tar components" do
        channel.expects(:exec).with("sh -l -c 'tar zxf - -C /etc/chef --strip-components=3'")
        connector.send_files(%w{ c d }, '/etc/chef', 3)
      end
    end
  end
end
