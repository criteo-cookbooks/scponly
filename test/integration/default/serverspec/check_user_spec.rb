#
# Cookbook Name:: scponly
# Description::		ServerSpec recipe
# Recipe::				check_user_spec
# Author::        Jeremy MAURO (j.mauro@criteo.com)
#
#
#

require 'serverspec'

# Required by serverspec
set :backend, :exec

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
      it { should contain 'This is a test' }
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
      it { should contain 'This is a test' }
    end
  end
end
