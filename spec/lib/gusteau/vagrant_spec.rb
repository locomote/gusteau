require './spec/spec_helper.rb'

describe Gusteau::Vagrant do
  let(:defaults) do
    {
      :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box',
      :cpus    => 64
    }
  end
  let(:prefix) { 'hyper' }
  let(:options) do
    {
      :defaults => defaults,
      :prefix => prefix
    }
  end

  describe "#vm_config" do
    let(:config_path) { './spec/nodes/staging.yml' }
    let(:node) { ::Gusteau::Node.new(config_path) }

    subject { Gusteau::Vagrant.vm_config(node, options) }

    let(:config_path) { './spec/nodes/development.yml' }

    let(:expected_label)  { 'hyper-development' }
    let(:expected_memory) { 1024 }

    let(:expected_config) do
      {
        :name    => 'development',
        :label   => expected_label,
        :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box',
        :ip      => '192.168.100.21',
        :cpus    => 4,
        :memory  => expected_memory
      }
    end

    def config_expectation
      subject.must_equal(expected_config)
    end

    specify { config_expectation }

    context "prefix not specified" do
      let(:prefix) { nil }
      let(:expected_label) { 'development' }

      specify { config_expectation }
    end

    context "different memory options" do
      let(:defaults) do
        {
          :memory => 4096,
          :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box'
        }
      end
      let(:expected_memory) { 4096 }

      specify { config_expectation }
    end

    context "box_url not specified" do
      let(:defaults) { {} }

      it "should raise an exception" do
        proc { subject }.must_raise RuntimeError
      end
    end
  end
end
