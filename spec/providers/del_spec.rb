
require 'spec_helper'

describe 'scponly_test::delete_user' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['scponly_user'],
      log_level: :debug,
      platform: 'centos',
      version: '6.5',
    ).converge(described_recipe)
  end

  before do
    stub_command('grep /usr/bin/scponly /etc/shells').and_return(true)
    stub_command('grep /usr/sbin/scponlyc /etc/shells').and_return(true)
    allow(::Dir).to receive(:glob).and_return([])
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'delete user "test_passwd_to_remove"' do
    expect(chef_run).to remove_user('test_passwd_to_remove').with(
      supports: { manage_home: false, non_unique: false },
    )
  end

  it 'delete user "chroot_to_remove_totally"' do
    expect(chef_run).to remove_user('chroot_to_remove_totally').with(
      supports: { manage_home: true },
    )
  end
end
