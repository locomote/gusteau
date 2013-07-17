# vi:ft=ruby:

%W(
  vagrant-omnibus
  gusteau
).each { |p| Vagrant.require_plugin(p) }

require 'gusteau'

Vagrant.configure('2') do |config|
  config.omnibus.chef_version = '11.4.4'

  Gusteau::Vagrant.detect(config) do |setup|
    setup.defaults.box = 'opscode-ubuntu-13.04'
    setup.defaults.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box'
    setup.prefix = Time.now.to_i
  end
end
