require './spec/spec_helper.rb'

describe Gusteau::SSHConfig do
  subject { Gusteau::SSHConfig.new('./spec') }

  let(:config) do
    <<-eos
# BEGIN GUSTEAU NODES

Host production
  HostName www.example.com
  Port 22
  User root

Host staging
  HostName staging.example.com
  Port 2222
  User devops

# END GUSTEAU NODES
    eos
  end

  it "should generate a valid SSH config" do
    subject.to_s.must_equal config
  end
end
