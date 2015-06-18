
require 'spec_helper'

describe 'scponly_test::add_user' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['scponly_user'],
      platform: 'centos',
      version: '6.5',
    ).converge(described_recipe)
  end

  before do
    stub_command('grep /usr/bin/scponly /etc/shells').and_return(true)
    stub_command('grep /usr/sbin/scponlyc /etc/shells').and_return(true)
    stub_command('grep chroot_test_passwd /var/opt/scponly-chroot/chroot_test_passwd/etc/passwd').and_return('chroot_test_passwd:x:901:901:user chroot_test_passwd:/incoming:/bin/false')
    stub_command('grep chroot_test_passwd /var/opt/scponly-chroot/chroot_test_passwd/etc/group').and_return('chroot_test_passwd:x:901')
    stub_command('grep chroot_test2_ssh_key /var/opt/scponly-chroot/chroot_test2_ssh_key/etc/passwd').and_return('chroot_test2_ssh_key:x:902:902:user chroot_test2_ssh_key:/incoming:/bin/false')
    stub_command('grep chroot_test2_ssh_key /var/opt/scponly-chroot/chroot_test2_ssh_key/etc/group').and_return('chroot_test2_ssh_key:x:902:')
    allow(::Dir).to receive(:glob).and_return([])
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'creates user "chroot_test_passwd"' do
    expect(chef_run).to create_user('chroot_test_passwd').with(
      password: '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.',
      home: '/var/opt/scponly-chroot/chroot_test_passwd//incoming',
      shell: '/usr/sbin/scponlyc',
    )
  end

  it 'creates user "chroot_test2_ssh_key"' do
    expect(chef_run).to create_user('chroot_test2_ssh_key').with(
      home: '/var/opt/scponly-chroot/chroot_test2_ssh_key//incoming',
      shell: '/usr/sbin/scponlyc',
    )
  end

  it 'creates "authorized_keys" for "chroot_test2_ssh_key"' do
    expect(chef_run).to create_file('/var/opt/scponly-chroot/chroot_test2_ssh_key/incoming/.ssh/authorized_keys').with(
      user: 'root',
      group: 'root',
      content: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDf/WTHmZdrXVbeCDl6Qtt27qcpNZPgTfSgcU6qzJgsPnlBIEddHMZTDziK+MFR2bYfMq1lWUyrZD83nmm/TZRxNAzn8TerEb6ERxsn9TFuTjkq8HmpSbhCq9a+2YlWk/lp/+oeJdZoQmNVB8xQ/g7uvuncxUPkKGHx4Smxeuq6Mw== test2@kitchen-test',
    )
  end

  it 'creates user "test_passwd"' do
    expect(chef_run).to create_user('test_passwd').with(
      home: '/home/test_passwd/incoming',
      shell: '/usr/bin/scponly',
      password: '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.',
    )
  end
end
