require './spec/spec_helper.rb'

describe Gusteau::Vagrant do
  let(:instance) { mock() }
  let(:subvm)    { stub_everything('subvm') }

  describe "#detect" do
    let(:config)     { mock() }
    let(:vm)         { mock() }
    let(:virtualbox) { stub_everything('virtualbox') }

    before do
      def vm.define(name); yield instance; end
      vm.expects(:instance).at_least_once.returns(instance)

      def subvm.provider(type); yield virtualbox; end
      subvm.expects(:virtualbox).at_least_once.returns(virtualbox)

      config.expects(:vm).at_least_once.returns(vm)
      instance.expects(:vm).at_least_once.returns(subvm)
    end

    it "should define vm instances with correct settings" do
      subvm.expects('box='.to_sym).with('b')
      subvm.expects('box_url='.to_sym).with("http://a.com/b.box")
      subvm.expects(:network).with(:private_network, { :ip => '192.168.100.21' })
      subvm.expects(:provision).never

      virtualbox.expects(:customize).with ['modifyvm', :id,
          '--memory', 1024,
          '--name', 'development-playground',
          '--cpus', 2,
          '--natdnsproxy1', 'on']

      Gusteau::Vagrant.detect(config) do |setup|
        setup.config_path = './spec/config/gusteau.yml'
        setup.defaults.box_url = "http://a.com/b.box"
      end
    end

    it "should define provisioner" do
      subvm.expects(:provision).with('chef_solo')

      Gusteau::Vagrant.detect(config) do |setup|
        setup.config_path = './spec/config/gusteau.yml'
        setup.defaults.box_url = "http://a.com/b.box"
        setup.provision = true
      end
    end
  end

  describe "internal methods" do
    before { Gusteau::Config.read("./spec/config/gusteau.yml") }
    let(:node) { Gusteau::Config.nodes['development-playground'] }

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

      let(:expected_label) { 'hyper-development-playground' }
      let(:expected_config) do
        {
          :name    => 'development-playground',
          :label   => expected_label,
          :box     => 'centos-6.4',
          :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box',
          :ip      => '192.168.100.21',
          :cpus    => 2,
          :memory  => 4096
        }
      end

      it "should merge in defaults" do
        subject.must_equal(expected_config)
      end

      context "prefix not specified" do
        let(:prefix) { nil }
        let(:expected_label) { 'development-playground' }

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

      context "box specified" do
        let(:defaults) do
          {
            :box     => 'custom_box_name',
            :box_url => 'https://opscode.s3.amazonaws.com/centos-6.4.box'
          }
        end

        it "should use default attribute" do
          subject[:box].must_equal "custom_box_name"
        end

        context "as node attribute" do
          let(:node) do
            Gusteau::Config.nodes['development-playground'].tap do |node|
              node.config['server']['vagrant']['box'] = 'another_box_name'
            end
          end

          it "should use node attribute" do
            subject[:box].must_equal 'another_box_name'
          end
        end
      end
    end

    describe "#define_provisioner" do
      let(:chef) { stub_everything('chef') }

      before do
        def subvm.provision(provider); yield chef; end
        subvm.expects(:chef).returns(chef)

        instance.expects(:vm).at_least_once.returns(subvm)
      end

      it "should set the correct Chef JSON" do
        chef.expects('json='.to_sym).with({"mysql"=>{"server_root_password"=>"guesswhat"}})
        Gusteau::Vagrant.define_provisioner(instance, node)
      end

      it "should set the correct Chef run_list" do
        chef.expects('run_list='.to_sym).with(["recipe[zsh]", "recipe[mysql::server]"])
        Gusteau::Vagrant.define_provisioner(instance, node)
      end
    end
  end
end
