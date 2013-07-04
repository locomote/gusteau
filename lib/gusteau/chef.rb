module Gusteau
  class Chef
    def initialize(server, platform = nil, dest_dir = '/etc/chef')
      @server   = server
      @platform = platform || 'omnibus'
      @dest_dir = dest_dir
    end

    def run(opts, dna)
      @server.run "rm -rf #{@dest_dir} && mkdir #{@dest_dir} && mkdir -p /tmp/chef"

      @server.upload(src_files(dna[:path]), @dest_dir, :exclude => '.git/')

      # move bootstrap directory to the top level
      @server.run "cd #{@dest_dir} && mv `find . -type d -name bootstrap` #{@dest_dir}/"

      @server.run "sh /etc/chef/bootstrap/#{@platform}.sh" if opts['bootstrap']

      cmd  = "chef-solo -c #{@dest_dir}/bootstrap/solo.rb -j #{@dest_dir + dna[:path]} --color"
      cmd << " -F #{opts['format']}"    if opts['format']
      cmd << " -l #{opts['log_level']}" if opts['log_level']
      cmd << " -W"                      if opts['why-run']
      @server.run cmd
    end

    private

    def src_files(dna_path)
      %W(
        #{dna_path}
        #{File.expand_path("../../../bootstrap", __FILE__)}
        ./cookbooks
        ./site-cookbooks
        ./roles
        ./data_bags
      ).select { |file| File.exists? file }
    end
  end
end
