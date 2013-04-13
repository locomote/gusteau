require './spec/spec_helper.rb'

describe Gusteau::SSHConfig do
  subject { Gusteau::SSHConfig.new('./spec') }

  let(:config) do
    <<-eos
# BEGIN GUSTEAU NODES

Host example-two
  HostName staging.exampletwo.com
  Port 2222
  User devops

Host example
  HostName server.example.com
  Port 22
  User root

# END GUSTEAU NODES
    eos
  end

  it "should generate a valid SSH config" do
    subject.to_s.must_equal config
  end
end
