require 'gusteau/erb'
require 'etc'
require 'json'
require 'fileutils'

module Gusteau
  class Bureau
    include Gusteau::ERB

    def initialize(name)
      @name = name
      @template_path = File.expand_path('../../../template', __FILE__)

      @login   = Etc.getlogin
      @ssh_key = File.read(File.expand_path '~/.ssh/id_rsa.pub').chomp rescue 'Your SSH key'

      abort "Directory #{name} already exists" if File.exists?(name)
    end

    def generate!(init = true)
      FileUtils.cp_r(@template_path, @name)
      template '.gusteau.yml'
      template 'README.md'
      template 'spec/example-box/platform_spec.rb'
      template "data_bags/users/#{@login}.json", "data_bags/users/user.json.erb"
      Dir.chdir(@name) { exec "bash ./init.sh #{@name} ; rm ./init.sh" } if(init)
    end

    private

    def template(dest, src = nil)
      src = "#{dest}.erb" unless src

      replace_template dest, src do |f|
        read_erb("#{@template_path}/#{src}").tap { |t| f.write(t) }
      end
    end

    def replace_template(dest, src)
      File.open("#{@name}/#{dest}", 'w+') do |f|
        yield f
        f.close
        FileUtils.rm("#{@name}/#{src}")
      end
    end

  end
end
