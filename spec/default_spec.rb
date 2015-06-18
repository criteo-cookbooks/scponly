#
#

require 'spec_helper'

describe 'scponly::default' do
  let(:chef_run) do
    chef_runner = ChefSpec::ServerRunner.new(
      platform: 'centos',
      version: '6.5',
    )
    chef_runner.converge(described_recipe)
  end

  before do
    stub_command('grep /usr/bin/scponly /etc/shells').and_return(false)
    stub_command('grep /usr/sbin/scponlyc /etc/shells').and_return(false)
  end

  it 'should install "scponly" package' do
    expect(chef_run).to install_package('scponly')
  end

  it 'creates "f2chroot.sh"' do
    expect(chef_run).to create_cookbook_file(File.join(Chef::Config[:file_cache_path], 'f2chroot.sh')).with(
      mode: '0755',
      source: 'f2chroot.sh',
    )
  end

  describe 'should run execute' do
    it 'do run execute' do
      expect(chef_run).to run_execute('echo /usr/bin/scponly >> /etc/shells')
      expect(chef_run).to run_execute('echo /usr/sbin/scponlyc >> /etc/shells')
    end
    it 'creates "f2chroot.sh"' do
      expect(chef_run).to create_cookbook_file(File.join(Chef::Config[:file_cache_path], 'f2chroot.sh')).with(
        mode: '0755',
        source: 'f2chroot.sh',
      )
    end
  end

  describe 'should not run execute' do
    before do
      stub_command('grep /usr/bin/scponly /etc/shells').and_return(true)
      stub_command('grep /usr/sbin/scponlyc /etc/shells').and_return(true)
    end
    it 'do not run execute' do
      expect(chef_run).to_not run_execute('echo /usr/bin/scponly >> /etc/shells')
      expect(chef_run).to_not run_execute('echo /usr/sbin/scponlyc >> /etc/shells')
    end
    it 'creates "f2chroot.sh"' do
      expect(chef_run).to create_cookbook_file(File.join(Chef::Config[:file_cache_path], 'f2chroot.sh')).with(
        mode: '0755',
        source: 'f2chroot.sh',
      )
    end
  end
end
