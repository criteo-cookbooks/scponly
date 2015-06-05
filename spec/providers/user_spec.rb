
require 'spec_helper'

describe 'scponly_test::add_user' do

  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['scponly_user'],
      log_level: :debug,
    ).converge(described_recipe)
  end

  before do
    stub_command("grep /usr/bin/scponly /etc/shells").and_return(true)
    stub_command("grep /usr/sbin/scponlyc /etc/shells").and_return(true)
    allow(::Dir).to receive(:glob).and_return([])
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'creates user "chroot_test_passwd"' do
    expect(chef_run).to create_user('chroot_test_passwd').with(
      password: '$6$YQpME/DN$4.h5fNLSg7FLHY3smHzYFCGoI6YpafMyO6QNHMoiGUKePYPSdn9LgSZrxzwLAdtRTgiPhAUZbp0uHcsGGjlJv.',
      home: '/var/opt/scponly-chroot/chroot_test_passwd//incoming',
      shell: '/bin/false',
    )
  end
end
