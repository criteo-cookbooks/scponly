#
# Cookbook Name:: scponly
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
include_recipe 'yum-epel'

node['scponly']['pkgs'].each do |pkg, vers|
  package pkg do
    version vers unless vers.nil?
  end
end

file '/sbin/scponlyc' do
  # Bug in the EPEL rpm the shell "/sbin/scponlyc" is not setuid dor user
  mode '4755'
end

node['scponly']['shells'].each do |name, conf|
  execute "Adding #{name} into system shells" do
    command "echo #{conf['path']} >> /etc/shells"
    not_if "grep #{conf['path']} /etc/shells"
  end
end

cookbook_file ::File.join(Chef::Config[:file_cache_path], 'f2chroot.sh') do
  mode '0755'
  source 'f2chroot.sh'
end
