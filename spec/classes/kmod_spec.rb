require 'spec_helper'

describe 'kmod', :type => :class do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('kmod') }
      it { should contain_file('/etc/modprobe.d').with({ 'ensure' => 'directory' }) }
      ['modprobe.conf','aliases.conf','blacklist.conf'].each do |file|
        it { should contain_file("/etc/modprobe.d/#{file}").with({ 'ensure' => 'file' }) }
      end
    end
  end
end
