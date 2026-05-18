#
# Cookbook Name:: scponly
# Description::		ServerSpec recipe
# Recipe::				check_user_spec
# Author::        Jeremy MAURO (j.mauro@criteo.com)
#
#
#

# Patch the User resource to be able to get authorized_keys content for the specified User instead of root
# See https://github.com/inspec/inspec/issues/7910 and remove once fixed
module InspecUserPatch
  # rubocop:disable Naming/AccessorMethodName
  def get_authorized_keys
    # cat is used in unix system to display content of file; similarly type is used for windows
    bin = inspec.os.windows? ? 'type' : 'cat'

    # auth_path gets assigned with the valid path for authorized_keys
    auth_path = ''

    # possible paths where authorized_keys are stored
    # inspec.command is used over inspec.file because inspec.file requires absolute path
    %W[~#{@username}/.ssh/authorized_keys ~#{@username}/.ssh/authorized_keys2].each do |path|
      if inspec.command("#{bin} #{path}").exit_status.zero?
        auth_path = path
        break
      end
    end

    # if auth_path is empty, no valid path was found, hence raise exception
    raise Inspec::Exceptions::ResourceSkipped, "Can't find any valid path for authorized_keys" if auth_path.empty?

    # authorized_keys are obtained in the standard output;
    # split keys on newline if more than one keys are part of authorized_keys
    inspec.command("#{bin} #{auth_path}").stdout.split("\n").map(&:strip)
  end
  # rubocop:enable Naming/AccessorMethodName
  require 'inspec/resources/user'
  Inspec::Resources::User.prepend self
end

describe package('scponly') do
  it { should be_installed }
end

describe 'Checking no chroot user' do
  describe 'user with password' do
    describe user('test_passwd') do
      it { should exist }
      it { should have_login_shell '/usr/bin/scponly' }
      it { should have_home_directory '/home/test_passwd/incoming' }
    end
    describe file('/home/test_passwd/incoming') do
      it { should be_directory }
      it { should be_owned_by 'test_passwd' }
    end
  end

  describe 'user to delete preserved home' do
    describe user('test_passwd_to_remove') do
      it { should_not exist }
    end
    describe file('/home/test_passwd_to_remove/incoming') do
      it { should be_directory }
    end
  end

  describe 'user with no password' do
    describe user('test2_ssh_key') do
      it { should exist }
      it { should have_login_shell '/usr/bin/scponly' }
      it { should have_home_directory '/home/test2_ssh_key/incoming' }
      it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test' }
    end
    describe file('/home/test2_ssh_key/incoming/copy_file') do
      it { should be_file }
      its('content') { should include 'This is a test' }
    end
  end
end

describe 'Checking chroot user' do
  describe 'user with password' do
    describe user('chroot_test_passwd') do
      it { should exist }
      it { should have_login_shell '/usr/sbin/scponlyc' }
      it { should have_home_directory '/var/opt/scponly-chroot/chroot_test_passwd//incoming' }
    end
    describe file('/var/opt/scponly-chroot/chroot_test_passwd/incoming') do
      it { should be_directory }
      it { should be_owned_by 'chroot_test_passwd' }
    end
  end

  describe 'user to delete totally' do
    describe user('chroot_to_remove_totally') do
      it { should_not exist }
    end
    describe file('/var/opt/scponly-chroot/home/chroot_to_remove_totally/incoming') do
      it { should_not be_directory }
      it { should_not be_file }
    end
  end

  describe 'user with no password' do
    describe user('chroot_test2_ssh_key') do
      it { should exist }
      it { should have_login_shell '/usr/sbin/scponlyc' }
      it { should have_home_directory '/var/opt/scponly-chroot/chroot_test2_ssh_key//incoming' }
      it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test' }
    end
    describe file('/var/opt/scponly-chroot/chroot_test2_ssh_key/incoming//copy_file') do
      it { should be_file }
      its('content') { should include 'This is a test' }
    end
  end
end
