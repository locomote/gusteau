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

      abort "Directory #{name} already exists" if Dir.exists?(name)
    end

    def generate!(init = true)
      FileUtils.cp_r(@template_path, @name)
      yaml_template '.gusteau.yml'
      text_template 'README.md'
      json_template "data_bags/users/#{@login}.json", "data_bags/users/user.json.erb"
      Dir.chdir(@name) { exec "bash ./init.sh #{@name} ; rm ./init.sh" } if(init)
    end

    private

    def yaml_template(file)
      replace_template file do |f|
        read_erb_yaml("#{@template_path}/#{file}.erb").tap { |c| f.write(c.to_yaml) }
      end
    end

    def json_template(file, src)
      replace_template file, src do |f|
        read_erb_json("#{@template_path}/#{src}").tap { |c| f.write JSON::pretty_generate(c) }
      end
    end

    def text_template(file)
      replace_template file do |f|
        read_erb("#{@template_path}/#{file}.erb").tap { |t| f.write t }
      end
    end

    def replace_template(file, src = nil)
      dest = "#{@name}/#{file}"
      src  = "#{@name}/#{src}" if(src)

      File.open(dest, 'w+') do |f|
        yield f
        f.close
        FileUtils.rm(src || "#{dest}.erb")
      end
    end

  end
end
