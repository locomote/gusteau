require 'gusteau/erb'
require 'etc'
require 'json'
require 'fileutils'

module Gusteau
  class Bureau
    include Gusteau::ERB

    def initialize(name)
      template_path = File.expand_path('../../../template', __FILE__)

      @login   = Etc.getlogin
      @ssh_key = File.read(File.expand_path '~/.ssh/id_rsa.pub').chomp rescue 'Your SSH key'

      abort "Directory #{name} already exists" if Dir.exists?(name)

      FileUtils.cp_r(template_path, name)

      File.open(File.join(name, '.gusteau.yml'), 'w+') do |f|
        read_erb_yaml(File.join(template_path, '.gusteau.yml.erb')).tap do |node|
          f.write node.to_yaml
          f.close
        end

        FileUtils.rm(File.join(name, '.gusteau.yml.erb'))
      end

      File.open(File.join(name, 'data_bags', 'users', "#{@login}.json"), 'w+') do |f|
        read_erb_json(File.join(template_path, 'data_bags', 'users', 'user.json.erb')).tap do |user|
          f.write JSON::pretty_generate user
          f.close
        end

        FileUtils.rm(File.join(name, 'data_bags', 'users', 'user.json.erb'))
      end

      puts "Created bureau '#{name}'"
      Dir.chdir(name) do
        system 'bash ./chop.sh ; rm ./chop.sh'
      end
    end
  end
end
