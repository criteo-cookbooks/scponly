name             'scponly'
maintainer       'Criteo'
maintainer_email 'j.mauro@criteo.com'
license          'Apache 2.0'
description      'Installs/Configures scponly'
issues_url       'https://github.com/criteo-cookbooks/scponly/issues' if respond_to?(:issue_url)
source_url       'https://github.com/criteo-cookbooks/scponly' if respond_to?(:source_url)
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          'yum-epel'
%w(centos rhel).each do |os|
  supports os
end
