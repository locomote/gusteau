module Gusteau
  class Chef

    def initialize(server, platform = nil, dest_dir = '/etc/chef')
      @server   = server
      @platform = platform || 'omnibus'
      @dest_dir = dest_dir
    end

    def run(dna, opts)
      @server.run "rm -rf #{@dest_dir} && mkdir #{@dest_dir} && mkdir -p /tmp/chef"

      with_src_files(dna[:path]) do |list|
        @server.upload list, @dest_dir, :exclude => '.git/', :strip_c => 2
      end

      @server.run "sh /etc/chef/bootstrap.sh" if opts['bootstrap']

      cmd  = "chef-solo -c #{@dest_dir}/solo.rb -j #{@dest_dir}/dna.json --color"
      cmd << " -F #{opts['format']}"    if opts['format']
      cmd << " -l #{opts['log_level']}" if opts['log_level']
      cmd << " -W"                      if opts['why-run']
      @server.run cmd
    end

    private

    def with_src_files(dna_path)
      tmp_dir       = FileUtils.mkdir_p("/tmp/gusteau-#{Time.now.to_i}")[0]
      bootstrap_dir = File.expand_path('../../../bootstrap', __FILE__)

      bootstrap = Gusteau::Config.settings['bootstrap'] || "#{bootstrap_dir}/#{@platform}.sh"

      {
        dna_path                               => "dna.json",
        bootstrap                              => "bootstrap.sh",
        "#{bootstrap_dir}/solo.rb"             => "solo.rb",
        'data_bags'                            => "data_bags",
        Gusteau::Config.settings['roles_path'] => "roles"
      }.tap do |f|
        Gusteau::Config.settings['cookbooks_path'].each_with_index do |path, i|
          f[path] = "cookbooks-#{i}"
        end

        f.each_pair do |src, dest|
          FileUtils.cp_r(src, "#{tmp_dir}/#{dest}") if File.exists?(src)
        end
      end

      yield [ tmp_dir ]
      FileUtils.rm_rf(tmp_dir)
    end
  end
end
