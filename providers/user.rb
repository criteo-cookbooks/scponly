#
# Cookbook Name::	scponly
# Description::		Provider for creating scponly users
# Recipe::				user
# Author::        Jeremy MAURO (j.mauro@criteo.com)
#
#
#

def whyrun_supported?
  true
end

use_inline_resources


action :delete do
  unless new_resource.preserved_home
    converge_by "removing chroot && home for #{new_resource.name}" do
      dir_name = new_resource.chroot_path || new_resource.home
      directory dir_name do
        recursive true
        action :delete
      end
    end
  end

  converge_by "removing user: #{new_resource.name}" do
    user new_resource.name do
      action :remove
    end
  end
end
