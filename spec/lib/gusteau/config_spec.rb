require './spec/spec_helper'

describe Gusteau::Config do
  context "config not found" do
    subject { Gusteau::Config.nodes("/tmp/nonexistent/nonsence111") }

    it "should exit with an error" do
      proc { subject }.must_raise SystemExit
    end
  end

  context "config is found" do
    let(:nodes) { Gusteau::Config.nodes("./spec/config/remi.yml") }

    it "should name nodes as per environment-node" do
      nodes.keys.must_equal ["production-db", "production-www"]
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
  end
end
