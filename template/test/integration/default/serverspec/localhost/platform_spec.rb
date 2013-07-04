require 'spec_helper'

describe 'platform role' do

  describe 'build-essential' do
    describe package('build-essential') do
      it { should be_installed }
    end

    describe command('gcc -v') do
      it { should return_exit_status 0 }
    end

    describe command('make -v') do
      it { should return_exit_status 0 }
    end
  end

  describe user('remi') do
    it { should exist }
    it { should belong_to_group 'wheel' }
    it { should have_login_shell '/bin/bash' }
    it { should have_authorized_key 'ABC123' }
  end
end
