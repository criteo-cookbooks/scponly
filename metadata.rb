name             'scponly'
maintainer       'Criteo'
maintainer_email 'sre-core-infra@criteo.com'
license          'Apache-2.0'
description      'Installs/Configures scponly'
long_description 'Scponly Cookbook
Install `scponly` package and configure `scponly` shells ([Scponly wiki](https://github.com/scponly/scponly/wiki))
'
issues_url       'https://github.com/criteo-cookbooks/scponly/issues' if respond_to?(:issues_url)
source_url       'https://github.com/criteo-cookbooks/scponly' if respond_to?(:source_url)
version          '1.2.0'
supports         'centos'
supports         'redhat'
depends          'yum-epel'
chef_version     '> 12.5.0' if respond_to?(:chef_version)
