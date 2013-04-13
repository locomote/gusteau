$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

module Gusteau
  require 'gusteau/node'
  require 'gusteau/bureau'
  require 'gusteau/ssh_config'
end
