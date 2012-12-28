module Gusteau
  class Chef
    def initialize(server, platform, dest_dir = '/etc/chef')
      @server   = server
      @platform = platform
      @dest_dir = dest_dir
    end

    def run(bootstrap, dna)
      upload_bureau dna[:path], @dest_dir

      @server.run "sh /etc/chef/bootstrap/#{@platform}.sh" if bootstrap
      @server.run "chef-solo -c #{@dest_dir}/bootstrap/solo.rb -j #{@dest_dir + dna[:path]}"
    end

    private

    def upload_bureau(dna_path, dest_dir)
      @server.run "rm -rf #{dest_dir} && mkdir #{dest_dir}"

      @server.upload %W(
        #{dna_path}
        #{File.expand_path("#{File.dirname(__FILE__)}/../../bootstrap")}
        ./cookbooks
        ./site-cookbooks
        ./roles
        ./data_bags
      ), dest_dir

      # move bootstrap directory to the top level
      @server.run "cd #{dest_dir} && mv `find . -type d -name bootstrap -print0` ."
    end
  end
end
