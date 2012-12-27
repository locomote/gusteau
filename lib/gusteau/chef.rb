module Gusteau
  class Chef
    def initialize(server, platform)
      @server   = server
      @platform = platform
    end

    def run(bootstrap, dna)
      @server.run "rm -rf /{etc,tmp}/chef && mkdir /{etc,tmp}/chef"
      @server.upload %W(
        #{dna[:path]}
        ./bootstrap
        ./cookbooks
        ./site-cookbooks
        ./roles
        ./data_bags
      ), '/etc/chef'
      @server.run "sh /etc/chef/bootstrap/#{@platform}.sh" if bootstrap
      @server.run "chef-solo -c /etc/chef/bootstrap/solo.rb -j /etc/chef/tmp/dna.json"
    end
  end
end
