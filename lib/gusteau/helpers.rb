require 'deep_merge'

class Hash
  def slice *keys
    select{|k| keys.member?(k)}
  end
end
