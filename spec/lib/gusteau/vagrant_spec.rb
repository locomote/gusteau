require './spec/spec_helper.rb'

describe Gusteau::Vagrant do

  describe "#detect" do
    let(:config)   { mock() }
    let(:vm)       { mock() }
    let(:instance) { mock() }
    let(:subvm)    { stub_everything('subvm') }

    before do
      def vm.define(name)
        yield instance
      end

      config.expects(:vm).at_least_once.returns(vm)
      vm.expects(:instance).at_least_once.returns(instance)
      instance.expects(:vm).at_least_once.returns(subvm)
    end

    it "should define vm instances with correct settings" do
      subvm.expects('box='.to_sym).with('development')
      subvm.expects('box_url='.to_sym).with("http://a.com/b.box")
      subvm.expects(:network).with(:private_network, { :ip => '192.168.100.21' })
      subvm.expects(:provision).never

      Gusteau::Vagrant.detect(config) do |setup|
        setup.dir = './spec/nodes'
        setup.defaults.box_url = "http://a.com/b.box"
      end
    end

    it "should define provisioner" do
      subvm.expects(:provision).with('chef_solo')

      Gusteau::Vagrant.detect(config) do |setup|
        setup.dir = './spec/nodes'
        setup.defaults.box_url = "http://a.com/b.box"
        setup.provision = true
      end
    end
  end

  describe "#vm_config" do
    subject { Gusteau::Vagrant.vm_config(node, options) }

    let(:defaults) do
      {
        :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box',
        :cpus    => 64,
        :memory  => 4096,
      }
    end
    let(:prefix)  { 'hyper' }
    let(:options) { { :defaults => defaults, :prefix => prefix } }

    let(:node) { ::Gusteau::Node.new('./spec/nodes/development.yml') }

    let(:expected_label) { 'hyper-development' }
    let(:expected_config) do
      {
        :name    => 'development',
        :label   => expected_label,
        :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box',
        :ip      => '192.168.100.21',
        :cpus    => 4,
        :memory  => 4096
      }
    end

    it "should merge in defaults" do
      subject.must_equal(expected_config)
    end

    context "prefix not specified" do
      let(:prefix) { nil }
      let(:expected_label) { 'development' }

      it "should omit the prefix" do
        subject.must_equal(expected_config)
      end
    end

    context "box_url not specified" do
      let(:defaults) { {} }

      it "should raise an exception" do
        proc { subject }.must_raise RuntimeError
      end
    end
  end
end
