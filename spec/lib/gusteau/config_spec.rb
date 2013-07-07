require './spec/spec_helper'

describe Gusteau::Config do
  context "config not found" do
    subject { Gusteau::Config.new("/tmp/nonexistent/nonsence111") }

    it "should exit with an error" do
      proc { subject }.must_raise SystemExit
    end
  end

  context "config is found" do
    let(:nodes) { Gusteau::Config.new("./spec/config/remi.yml").nodes }

    it "should name nodes as per environment-node" do
      nodes.keys.sort.must_equal ["production-db", "production-www", "staging-vm"]
    end

    it "should override run_list if defined for a node" do
      nodes['production-db'].config['run_list'].must_equal(["recipe[git]", "recipe[postgresql::server]"])
      nodes['production-www'].config['run_list'].must_equal(["recipe[varnish]", "recipe[nginx]"])
    end

    it "should deeply merge the attributes" do
      nodes['production-db'].config['attributes'].must_equal({
        'users' => ['alex', 'simon'],
        'mysql' => {'server_port' => 3307, 'server_root_password' => 'prodsecret' }
      })
    end

    it "should override the global before hook with an environment one" do
      nodes['production-www'].config['before'].must_equal(['bundle exec berks install'])
      nodes['staging-vm'].config['before'].must_equal(['echo "Hello World!"'])
    end
  end
end
