require 'gusteau/erb'

module Gusteau
  class Chef
    include Gusteau::ERB

    def initialize(server, platform = nil)
      @server   = server
      @platform = platform || 'omnibus'
    end

    def run(dna, opts)
      dest_dir = Gusteau::Config.settings['chef_config_dir']
      @server.run "rm -rf #{dest_dir} && mkdir #{dest_dir} && mkdir -p /tmp/chef"

      with_gusteau_dir(dna[:path]) do |dir|
        @server.upload [dir], dest_dir, :exclude => '.git/', :strip_c => 2
      end

      @server.run "sh /etc/chef/bootstrap.sh #{Gusteau::Config.settings['chef_version']}" if opts['bootstrap']

      cmd  = "unset GEM_HOME; unset GEM_PATH; chef-solo -c #{dest_dir}/solo.rb -j #{dest_dir}/dna.json --color"
      cmd << " -F #{opts['format']}"    if opts['format']
      cmd << " -l #{opts['log_level']}" if opts['log_level']
      cmd << " -W"                      if opts['why-run']
      @server.run cmd
    end

    private

    def files_list(dna_path)
      bootstrap_dir = File.expand_path('../../../bootstrap', __FILE__)
      bootstrap = Gusteau::Config.settings['bootstrap'] || "#{bootstrap_dir}/#{@platform}.sh"

      {
        dna_path                               => "dna.json",
        bootstrap                              => "bootstrap.sh",
        "#{bootstrap_dir}/solo.rb.erb"         => "solo.rb",
        'data_bags'                            => "data_bags",
        Gusteau::Config.settings['roles_path'] => "roles"
      }.tap do |f|
        Gusteau::Config.settings['cookbooks_path'].each_with_index do |path, i|
          f[path] = "cookbooks-#{i}"
        end
      end
    end

    def with_gusteau_dir(dna_path)
      tmp_dir = "/tmp/gusteau-#{Time.now.to_i}"
      FileUtils.mkdir_p(tmp_dir)

      files_list(dna_path).each_pair do |src, dest|
        if File.exists?(src)
          if File.extname(src) == '.erb'
            File.open("#{tmp_dir}/#{dest}", "w" ) do |f|
              f.write read_erb(src)
            end
          else
            FileUtils.cp_r(src, "#{tmp_dir}/#{dest}")
          end
        end
      end

      yield tmp_dir
      FileUtils.rm_rf(tmp_dir)
    end
  end
end
