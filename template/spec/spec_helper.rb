require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'gusteau'

include Serverspec::Helper::Ssh
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.color = true
  c.formatter = :doc

  c.before :all do
    block = self.class.metadata[:example_group_block]
    file = block.source_location.first
    nodename = File.basename(Pathname.new(file).dirname)

    Gusteau::Config.read('.gusteau.yml')
    server = Gusteau::Config.nodes[nodename].config['server']

    if c.host != server['host']
      c.ssh.close if c.ssh
      c.host = server['host']
      user   = server['user'] || 'root'
      opts   = server['password'] ? { :password => server['password'] } : {}
      c.ssh  = Net::SSH.start(c.host, user, opts)
    end
  end
end
