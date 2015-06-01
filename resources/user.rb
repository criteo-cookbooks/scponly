#
# Cookbook Name::	scponly
# Description::		Resource user
# Recipe::				user
# Author::        Jeremy MAURO (j.mauro@criteo.com)
#
#
#

actions :create, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :chrooted, kind_of: [TrueClass, FalseClass], default: true
attribute :home, kind_of: String, default: '/incoming'
attribute :chroot_path, kind_of: String, default: '/var/opt/scponly-chroot'
attribute :password, kind_of: String, default: nil
attribute :ssh_keys, kind_of: Array, default: nil
attribute :preserved_home, kind_of: [TrueClass, FalseClass], default: true
