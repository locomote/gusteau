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
      assert Dir.exists?(bureau_path)

      %w{ Berksfile Vagrantfile .kitchen.yml }.each do |f|
        assert File.exists?("#{bureau_path}/#{f}")
      end

      %w{ data_bags site-cookbooks test }.each do |d|
        assert Dir.exists?("#{bureau_path}/#{d}")
      end
    end

    it "should process the README template" do
      readme_path = "#{bureau_path}/README.md"
      assert File.exists?(readme_path)
      assert File.read(readme_path).include?("Welcome to your example Chef-Repo, #{login}")
    end

    it "should process the .gusteau.yml template" do
      config_path = "#{bureau_path}/.gusteau.yml"
      assert File.exists?(config_path)
      assert File.read(config_path).include?("Good job, #{login}")
    end

    it "should process the user data_bag template" do
      config_path = "#{bureau_path}/data_bags/users/#{login}.json"
      assert File.exists?(config_path)
      assert File.read(config_path).include?(login)
    end
  end

end
