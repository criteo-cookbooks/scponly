#
# Cookbook Name::	scponly
# Description::		Default attributes for scponly
# Recipe::				default
# Author::        Jeremy MAURO (j.mauro@criteo.com)
#
#
#

default['scponly']['pkgs']['scponly'] = nil
default['scponly']['shells']['scponly']['path']  = '/usr/bin/scponly'
default['scponly']['shells']['scponlyc']['path'] = '/usr/sbin/scponlyc'
