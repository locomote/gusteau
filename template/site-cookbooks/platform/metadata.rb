name             'platform'
maintainer       'Vasily Mikhaylichenko'
maintainer_email 'vasily@locomote.com.au'
license          'BSD'
description      'Base OS configuration'
version          '1.0.0'

%w{ ubuntu debian }.each do |os|
  supports os
end

depends 'apt'
depends 'build-essential'
depends 'user'
