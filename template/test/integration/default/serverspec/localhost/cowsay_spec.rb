require 'spec_helper'

describe package('cowsay') do
  it { should be_installed }
end
