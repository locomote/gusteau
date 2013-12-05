require './spec/spec_helper'

describe Gusteau::Config do
  context "config not found" do
    subject { Gusteau::Config.read("/tmp/nonexistent/nonsence111") }

    it "should exit with an error" do
      proc { subject }.must_raise SystemExit
    end
  end

  context "config is found" do
    before { Gusteau::Config.read("./spec/config/remi.yml") }

    describe "#nodes" do
      let(:nodes) { Gusteau::Config.nodes }

      it "should name nodes as per environment-node" do
        nodes.keys.sort.must_equal ["production-db", "production-www", "staging-vm"]
      end

      it "should override run_list if defined for a node" do
        nodes['production-db'].config['run_list'].must_equal(["recipe[git]", "recipe[postgresql::server]"])
        nodes['production-www'].config['run_list'].must_equal(["recipe[varnish]", "recipe[nginx]"])
      end

      it "should deeply merge the attributes" do
        nodes['production-db'].config['attributes'].must_equal({
          'net'   => {'hostname' => 'prod-db'},
          'users' => ['alex', 'simon'],
          'mysql' => {'server_port' => 3307, 'server_root_password' => 'prodsecret' }
        })
      end

      it "should override the global before hook with an environment one" do
        nodes['production-www'].config['before'].must_equal(['bundle exec berks install'])
        nodes['staging-vm'].config['before'].must_equal(['echo "Hello World!"'])
      end
    end

    describe "#settings" do
      let(:settings) { Gusteau::Config.settings }

      it "should have defaults for cookbooks_path, roles_path, bootstrap, chef_version, chef_config_dir" do
        settings['cookbooks_path'].must_equal ['cookbooks', 'site-cookbooks']
        settings['roles_path'].must_equal 'roles'
        settings['bootstrap'].must_equal nil
        settings['chef_version'].must_equal Gusteau::Config::DEFAULT_CHEF_VERSION
        settings['chef_config_dir'].must_equal Gusteau::Config::DEFAULT_CHEF_CONFIG_DIRECTORY
      end

      context "settings defined in the config yml" do
        before { Gusteau::Config.read("./spec/config/emile.yml") }

        it "should have defaults for cookbooks_path, roles_path, chef_version" do
          settings['cookbooks_path'].must_equal ['private-cookbooks', '/home/user/.cookbooks']
          settings['roles_path'].must_equal 'basic-roles'
          settings['chef_version'].must_equal '10.26.0'
          settings['chef_config_dir'].must_equal '/etc/custom_chef_dir'
        end
      end
    end
  end
end
