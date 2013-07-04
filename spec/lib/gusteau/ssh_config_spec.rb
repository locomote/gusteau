require './spec/spec_helper.rb'

describe Gusteau::SSHConfig do
  let(:nodes) { Gusteau::Config.nodes("./spec/config/gusteau.yml") }
  subject { Gusteau::SSHConfig.new(nodes) }

  let(:config) do
    <<-eos
# BEGIN GUSTEAU NODES

Host development-playground
  HostName 192.168.100.21
  Port 22
  User root

Host staging-www
  HostName staging.myapp.com
  Port 22
  User root

Host production-db
  HostName db.myapp.com
  Port 22
  User billy

Host production-www
  HostName www.myapp.com
  Port 22
  User billy

# END GUSTEAU NODES
    eos
  end

  it "should generate a valid SSH config" do
    subject.to_s.must_equal config
  end
end
