# frozen_string_literal: true

require 'spec_helper'

describe 'kmod', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} with default parameters" do
      let(:facts) do
        facts.merge(augeasversion: '1.2.0')
      end

      it { is_expected.to contain_class('kmod') }

      it do
        is_expected.to contain_file('/etc/modprobe.d').with(
          'ensure' => 'directory',
          'owner' => 'root',
          'group' => 'root',
          'mode' => '0755'
        )
      end

      ['modprobe.conf', 'aliases.conf', 'blacklist.conf'].each do |file|
        it do
          is_expected.to contain_file("/etc/modprobe.d/#{file}").with(
            'ensure' => 'file',
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644'
          )
        end
      end
    end

    context "on #{os} with modified file permissions" do
      let(:facts) do
        facts.merge(augeasversion: '1.2.0')
      end
      let(:params) do
        {
          'owner' => 'adm',
          'group' => 'sys',
          'directory_mode' => '0711',
          'file_mode' => '0640',
        }
      end

      it { is_expected.to contain_class('kmod') }

      it do
        is_expected.to contain_file('/etc/modprobe.d').with(
          'ensure' => 'directory',
          'owner' => params['owner'],
          'group' => params['group'],
          'mode' => params['directory_mode']
        )
      end

      ['modprobe.conf', 'aliases.conf', 'blacklist.conf'].each do |file|
        it do
          is_expected.to contain_file("/etc/modprobe.d/#{file}").with(
            'ensure' => 'file',
            'owner' => params['owner'],
            'group' => params['group'],
            'mode' => params['file_mode']
          )
        end
      end
    end

    context "on #{os} with hash parameters" do
      let(:facts) do
        facts.merge({ augeasversion: '1.2.0' })
      end
      let(:params) do
        {
          'list_of_blacklists' => {
            'foo01' => {},
            'foo02' => {},
            'foo03' => {},
          },
          'list_of_aliases' => {
            'foo01' => {
              'source' => 'squashfs',
              'aliasname' => 'squash01',
            },
            'foo02' => {
              'source' => 'squashfs',
              'aliasname' => 'squash02',
            },
          },
          'list_of_installs' => {
            'dccp' => {
              'command' => '/bin/false',
            },
            'blah' => {
              'command' => '/bin/true',
            },
          },
          'list_of_loads' => {
            'cramfs' => {},
            'vfat' => {},
          },
          'list_of_options' => {
            'bond0 mode' => {
              'module' => 'bond0',
              'option' => 'mode',
              'value' => '1',
            },
            'bond0' => {
              'option' => 'mode',
              'value' => '1',
            },
          },
        }
      end

      it do
        params['list_of_blacklists'].each do |key, value|
          is_expected.to contain_kmod__blacklist(key).with(value)
        end
      end

      it do
        params['list_of_aliases'].each do |key, value|
          is_expected.to contain_kmod__alias(key).with(value)
        end
      end

      it do
        params['list_of_installs'].each do |key, value|
          is_expected.to contain_kmod__install(key).with(value)
        end
      end

      it do
        params['list_of_loads'].each do |key, value|
          is_expected.to contain_kmod__load(key).with(value)
        end
      end

      it do
        params['list_of_options'].each do |key, value|
          is_expected.to contain_kmod__option(key).with(value)
        end
      end
    end
  end
end
