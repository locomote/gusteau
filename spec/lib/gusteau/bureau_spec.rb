require './spec/spec_helper'
require 'fileutils'
require 'etc'

describe Gusteau::Bureau do

  let(:login) { Etc.getlogin }
  let(:bureau_path) { "/tmp/gusteau-test/bureau" }

  before { FileUtils.mkdir_p("/tmp/gusteau-test") }
  after  { FileUtils.rm_rf(bureau_path) }

  subject { Gusteau::Bureau.new(bureau_path) }

  it "should obtain the correct user login" do
    subject.instance_variable_get("@login").must_equal login
  end

  describe "#generate!" do
    before { subject.generate!(false) }
    it "should create a basic structure" do
      assert File.exists?(bureau_path)

      %w{ Berksfile Vagrantfile }.each do |f|
        assert File.exists?("#{bureau_path}/#{f}")
      end

      %w{ data_bags site-cookbooks spec }.each do |d|
        assert File.exists?("#{bureau_path}/#{d}")
      end
    end

    it "should process the README template" do
      readme_path = "#{bureau_path}/README.md"
      assert File.exists?(readme_path)
      assert File.read(readme_path).include?("Welcome to your example Chef-Repo, #{login}")
    end

    describe ".gusteau.yml" do
      let(:config_path) { "#{bureau_path}/.gusteau.yml" }

      it "should should exist" do
        assert File.exists?(config_path)
      end

      describe "template contents" do
        before     { Gusteau::Config.read(config_path) }
        let(:node) { Gusteau::Config.nodes['example-box'] }

        let(:server)     { node.config['server'] }
        let(:attributes) { node.config['attributes'] }

        it "should contain a personalized greeting" do
          attributes['cowsay']['greeting'].must_equal "Good job, #{login}!"
        end

        it "should invoke user creation" do
          attributes['users'].must_equal [ login ]
        end

        it "should set a randomized ip address" do
          ip_regexp = /33\.33\.\d{1,3}\.\d{1,3}/
          server['host'].must_match ip_regexp
          server['vagrant']['IP'].must_match ip_regexp
        end
      end
    end

    it "should process the user data_bag template" do
      config_path = "#{bureau_path}/data_bags/users/#{login}.json"
      assert File.exists?(config_path)
      assert File.read(config_path).include?(login)
    end
  end

end
