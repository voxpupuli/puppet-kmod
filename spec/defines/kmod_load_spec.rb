require 'spec_helper'

describe 'kmod::load', :type => :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with ensure set to present' do
        let(:params) do { :ensure => 'present', :file => '/foo/bar' } end
        it { should contain_kmod__load('foo') }
        it { should contain_exec('modprobe foo').with({'unless' => "egrep -q '^foo ' /proc/modules"}) }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_augeas('Manage foo in /foo/bar').with({
            'incl'    => '/foo/bar',
            'lens'    => 'Modules.lns',
            'changes' => "clear 'foo'"
          }) }
        when 'RedHat'
          it { should contain_file('/etc/sysconfig/modules/foo.modules').with({
            'ensure'  => 'present',
            'mode'    => '0755',
            'content' => /exec \/sbin\/modprobe foo > \/dev\/null 2>&1/
          })}
        end
      end

      context 'with ensure set to absent' do
        let(:params) do { :ensure => 'absent', :file => '/foo/bar' } end
        it { should contain_kmod__load('foo') }
        it { should contain_exec('modprobe -r foo').with({ 'onlyif' => "egrep -q '^foo ' /proc/modules" }) }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_augeas('Manage foo in /foo/bar').with({
            'incl'    => '/foo/bar',
            'lens'    => 'Modules.lns',
            'changes' => "rm 'foo'"
          })}
        when 'RedHat'
          it { should contain_file('/etc/sysconfig/modules/foo.modules').with({
            'ensure'  => 'absent',
            'mode'    => '0755',
            'content' => /exec \/sbin\/modprobe foo > \/dev\/null 2>&1/
          })}
        end
      end
    end
  end
end
