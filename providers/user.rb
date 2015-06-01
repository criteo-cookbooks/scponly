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

def load_current_resource
  @os_family = node['platform_family']
  @scponly   = node['scponly']['shells']['scponly']
  @scponlyc  = node['scponly']['shells']['scponlyc']
end

def binaries_list(os_family)
  # This list is extracted from the scponly file: BUILDING-JAILS.TXT
  bin_list = [
    '/bin/chmod',
    '/bin/chown',
    '/bin/chgrp',
    '/bin/echo',
    '/bin/ln',
    '/bin/ls',
    '/bin/mkdir',
    '/bin/mv',
    '/bin/pwd',
    '/bin/rm',
    '/bin/rmdir',
    '/etc/ld.so.cache',
    '/etc/ld.so.conf',
    '/usr/bin/id',
    '/usr/bin/groups',
    '/usr/bin/rsync',
    '/usr/bin/scp',
  ]
  case os_family
  when /(?i-mx:debian)/
    bin_list << '/usr/lib/openssh/sftp-server'
    # Now the glibc compat libraries
    lib_path = '/lib'
  when /(?i-mx:rhel)/
    bin_list << '/usr/libexec/openssh/sftp-server'
    # Now the glibc compat libraries
    lib_path = '/lib64'
  end
  bin_list.concat(::Dir.glob(::File.join(lib_path, '**', 'libnss_*'))).sort
end

action :create do
  if new_resource.chrooted
    user_chroot_path = ::File.join(new_resource.chroot_path, new_resource.name)
    dev_chroot_path  = ::File.join(user_chroot_path, 'dev')
    f2chroot         = ::File.join(Chef::Config[:file_cache_path], 'f2chroot.sh')

    converge_by "creating chroot environment for #{new_resource.name}" do
      binaries_list(@os_family).each do |binary|
        execute "Copying #{binary} and dependencies into chroot" do
          command "#{f2chroot} -r #{user_chroot_path} #{binary}"
          creates ::File.join(user_chroot_path, binary)
        end
      end
    end
    # --[ SCPONLY: Everything before the // is the directory to chroot into and
    # everything after the // is the subdir to chdir into after chrooting. ]--
    user_home  = user_chroot_path + '/' + new_resource.home
    user_shell = @scponlyc['path']

    directory dev_chroot_path

    execute "Creating null device for #{new_resource.name}" do
      command 'mknod -m 666 null c 1 3'
      cwd dev_chroot_path
      creates ::File.join(dev_chroot_path, 'null')
    end

  else
    user_home  = new_resource.home
    user_shell = @scponly['path']
  end

  converge_by "creating user: #{new_resource.name}" do
    user new_resource.name do
      comment "SCPONLY user #{new_resource.name}"
      home user_home
      shell user_shell
      password new_resource.password
    end

    directory user_home do
      user new_resource.name
      group new_resource.name
    end
  end

  if new_resource.chrooted
    converge_by "creating authentification files for #{new_resource.name}" do
      passwd_file = ::File.join(user_chroot_path, 'etc', 'passwd')
      group_file  = ::File.join(user_chroot_path, 'etc', 'group')

      execute "Creating for #{new_resource.name} /etc/passwd" do
        command "egrep \"^root|#{new_resource.name}\" /etc/passwd | \
          sed -e 's@#{user_home}@#{new_resource.home}@g' \
            -e 's/SCPONLY\ //g' \
            -e 's@#{user_shell}@/bin/false@g' > #{passwd_file}"
        not_if "grep #{new_resource.name} #{passwd_file}"
      end

      execute "Creating for #{new_resource.name}/etc/group" do
        command "egrep \"^root|#{new_resource.name}|users\" /etc/group > #{group_file}"
        not_if "grep #{new_resource.name} #{group_file}"
      end
    end
  end
end

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
