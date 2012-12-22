module Gusteau
  class Chef
    def initialize(server, platform)
      @server   = server
      @platform = platform
    end

    def bootstrap
      bootstrap_script = File.read("bootstrap/#{@platform}.sh")
      rescue
        raise "Server platform not specified or unknown"
      else
        @server.run [bootstrap_script, 'mkdir -p /{etc,tmp}/chef']
        @server.upload %w{bootstrap/solo.rb}, '/etc/chef'
    end

    def run(dna)
      @server.upload %W(#{dna[:path]} ./cookbooks ./site-cookbooks ./roles ./data_bags), '/etc/chef'
      @server.run    'chef-solo -c /etc/chef/bootstrap/solo.rb -j /etc/chef/tmp/dna.json'
    end
  end
end
