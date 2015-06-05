Scponly Cookbook
================
Install `scponly` package and configure `scponly` shells ([Scponly wiki](https://github.com/scponly/scponly/wiki))

Requirements
------------
- Chef 11 or higher

### Platform
The release was tested on:
* RHEL 6.X
* CentOS 6.X

Cookbook Dependencies
------------
- yum-epel

Attributes
----------
- `node['scponly']['pkgs']` - packages' name to install (default: `[ "scponly" ]`)
- `node['scponly']['shell']['scponly']['path']` - the shell path for `scponly` shell (default: `/usr/bin/scponly`)
- `node['scponly']['shells']['scponlyc']['path']` - the shell path for `scponlyc` shell (default: `/usr/sbin/scponlyc`)

-------
### default
This recipe setup all the basics needed to create chroot or nochroot user with `scponly` shells

Resources/Providers
-------------------
### `scponly_user`
This LWRP provides an easy way to create `scponly` users

#### Actions
- `:create`: creates user
- `:delete`: removes user and possibly its home

#### Attribute Parameters
- `name`: name attribute. The name of the user
- `chrooted`: does the user need a chrooted environment (default: `true`)
- `home`: provides the user's home path inside the chroot environment if one (default: `/incoming`)
- `chroot_path`: the path where to create the chroot environment if needed (default: `/var/opt/scponly-chroot`)
- `password`: the encrypted user password (default: `nil`)
- `ssh_keys`: array with all the `authorized_keys` for the user (default: `nil`)
- `preserved_home`: in case of deletion does the user home has to remain (default: `true`)

#### Examples

Add a chrooted user with password:
```ruby
scponly_user 'chroot_test_passwd' do
  chrooted true
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end
```
Add a chrooted user with ssh_keys:
```ruby
scponly_user 'chroot_test2_ssh_key' do
  chrooted true
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test']
end
```
Add a non chroot user
```ruby
scponly_user 'test_passwd' do
  chrooted false
  home '/home/test_passwd/incoming'
  # Setting passwd to 'test'
  password '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.'
end
```

Usage
-----
This cookbook should preferably be used by including this recipe into a cookbook wrapper which actually creates scponly users as described in the examples.

License & Authors
-----------------
- Author:: Jeremy MAURO (jmauro@criteo.com)


```text
Copyright 2009-2015, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
