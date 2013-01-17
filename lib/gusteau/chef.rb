module Gusteau
  class Chef
    def initialize(server, platform, dest_dir = '/etc/chef')
      @server   = server
      @platform = platform
      @dest_dir = dest_dir
    end

    def run(opts, dna)
      @server.sync_files src_files(dna[:path]), @dest_dir

      @server.run "sh /etc/chef/bootstrap/#{@platform}.sh" if opts['bootstrap']

      cmd  = "chef-solo -c #{@dest_dir}/bootstrap/solo.rb -j #{@dest_dir}/dna.json --color"
      cmd += " -F #{opts['format']}"    if opts['format']
      cmd += " -l #{opts['log_level']}" if opts['log_level']
      cmd += " -W"                      if opts['why-run']
      @server.run cmd
    end

    private

    def src_files(dna_path)
      %W(
        #{dna_path}
        #{File.expand_path("../../../bootstrap", __FILE__)}
        cookbooks
        site-cookbooks
        roles
        data_bags
      ).select { |file| File.exists? file }
    end
  end
end
