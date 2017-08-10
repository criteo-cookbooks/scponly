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
  bin_original = [
    '/bin/chmod',
    '/bin/chown',
    '/bin/chgrp',
    '/bin/echo',
    '/bin/id',
    '/bin/groups',
    '/bin/ln',
    '/bin/ls',
    '/bin/mkdir',
    '/bin/mv',
    '/bin/pwd',
    '/bin/rm',
    '/bin/rmdir',
    '/bin/rsync',
    '/bin/scp',
    '/etc/ld.so.cache',
    '/etc/ld.so.conf',
    '/usr/bin/id',
    '/usr/bin/groups',
    '/usr/bin/rsync',
    '/usr/bin/scp',
  ]
  bin_list = []
  # Making sure the binary is present
  bin_original.each do |binary|
    bin_list << binary if ::File.exist?(binary)
  end
  case os_family
  when /(?i-mx:debian)/
    bin_list << '/usr/lib/openssh/sftp-server'
    lib_path = '/lib'
  when /(?i-mx:rhel)/
    bin_list << '/usr/libexec/openssh/sftp-server'
    lib_path = '/lib64'
  end
  # Now the glibc compat libraries
  bin_list.concat(::Dir.glob(::File.join(lib_path, '**', 'libnss_*'))).sort
end

action :create do
  if new_resource.chrooted
    user_chroot_path = ::File.join(new_resource.chroot_path, new_resource.name)
    dev_chroot_path  = ::File.join(user_chroot_path, 'dev')
    f2chroot         = ::File.join(Chef::Config[:file_cache_path], 'f2chroot.sh')

    directory dev_chroot_path do
      recursive true
    end

    binaries_list(@os_family).each do |binary|
      execute "#{new_resource.name}: Copying #{binary} and dependencies into chroot" do
        command "#{f2chroot} -r #{user_chroot_path} #{binary}"
        creates ::File.join(user_chroot_path, binary)
      end
    end
    # --[ SCPONLY: Everything before the // is the directory to chroot into and
    # everything after the // is the subdir to chdir into after chrooting. ]--
    user_home  = user_chroot_path + '/' + new_resource.home
    user_shell = @scponlyc['path']

    execute "#{new_resource.name}: Creating null device for #{new_resource.name}" do
      command 'mknod -m 666 null c 1 3'
      cwd dev_chroot_path
      creates ::File.join(dev_chroot_path, 'null')
    end

  else
    user_home  = new_resource.home
    user_shell = @scponly['path']
  end

  directory ::File.dirname(user_home) do
    recursive true
  end

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

  if new_resource.chrooted
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

  if new_resource.ssh_keys
    user_chroot_path ||= ''
    ssh_dir = ::File.join(user_chroot_path, new_resource.home, '.ssh')

    directory ssh_dir do
      user 'root'
      group 'root'
      mode '0755'
    end

    file ::File.join(ssh_dir, 'authorized_keys') do
      owner 'root'
      group 'root'
      mode '0644'
      content new_resource.ssh_keys.join("\n")
    end
  end
end

action :delete do
  user new_resource.name do # ~FC009
    unless new_resource.preserved_home
      manage_home true
      force true if Chef::VERSION.to_s.to_i > 12
    end
    action :remove
  end
end
