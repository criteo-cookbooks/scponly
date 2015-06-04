#
# Cookbook Name:: scponly_test
# Recipe:: default
#
# Copyright 2015, Criteo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'scponly'

['id_rsa_test2'].each do |name|
  cookbook_file ::File.join(Chef::Config[:file_cache_path], name) do
    mode '0600'
    source name
  end
end

file '/tmp/copy_file' do
  content 'This is a test'
end

scponly_user 'chroot_test_passwd' do
  # Setting passwd to 'test'
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end

scponly_user 'chroot_test2_ssh_key' do
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test']
end

scponly_user 'test_passwd' do
  chrooted false
  home '/home/test_passwd/incoming'
  # Setting passwd to 'test'
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end

scponly_user 'test_passwd_to_remove' do
  chrooted false
  home '/home/test_passwd_to_remove/incoming'
  # Setting passwd to 'test'
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end

scponly_user 'chroot_to_remove_totally' do
  home '/home/chroot_to_remove_totally/incoming'
  # Setting passwd to 'test'
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end

scponly_user 'test2_ssh_key' do
  chrooted false
  home '/home/test2_ssh_key/incoming'
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test']
end

scp_args = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{::File.join(Chef::Config[:file_cache_path], 'id_rsa_test2')}"
execute 'Testing user "chroot_test2_ssh_key"' do
  command "scp #{scp_args} /tmp/copy_file chroot_test2_ssh_key@localhost:"
end

execute 'Testing user "test2_ssh_key"' do
  command "scp #{scp_args} /tmp/copy_file test2_ssh_key@localhost:"
end

# --[ Removing users ]--
scponly_user 'test_passwd_to_remove' do
  action :delete
end

scponly_user 'chroot_to_remove_totally' do
  preserved_home false
  action :delete
end
