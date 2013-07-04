name             'cowsay'
maintainer       'Vasily Mikhaylichenko'
maintainer_email 'vasily@locomote.com.au'
license          'BSD'
description      'Installs cowsay and displays a greeting'
version          '1.0.0'

%w{redhat centos ubuntu gentoo}.each do |os|
  supports os
end
