# frozen_string_literal: true

require 'spec_helper'

describe 'kmod::load', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ augeasversion: '1.2.0' })
      end

      context 'with ensure set to present' do
        let(:params) { { ensure: 'present' } }

        it { is_expected.to contain_kmod__load('foo') }

        it {
          is_expected.to contain_exec('modprobe foo').
            with('unless' => "grep -qE '^foo ' /proc/modules")
        }

        context 'when on systemd' do
          it {
            is_expected.to contain_file('/etc/modules-load.d/foo.conf').
              with('ensure' => 'present',
                   'mode' => '0644',
                   'content' => "# This file is managed by the puppet kmod module.\nfoo\n")
          }
        end
      end

      context 'with ensure set to absent' do
        let(:params) { { ensure: 'absent', } }

        it { is_expected.to contain_kmod__load('foo') }

        it {
          is_expected.to contain_exec('modprobe -r foo').
            with('onlyif' => "grep -qE '^foo ' /proc/modules")
        }

        context 'when on systemd' do
          it {
            is_expected.to contain_file('/etc/modules-load.d/foo.conf').
              with('ensure' => 'absent',
                   'mode' => '0644',
                   'content' => "# This file is managed by the puppet kmod module.\nfoo\n")
          }
        end
      end

      context 'when file permissions are specified' do
        let(:params) { { ensure: 'present', } }
        let(:pre_condition) do
          <<~END
            class { 'kmod':
              owner     => 'adm',
              group     => 'sys',
              file_mode => '0600',
              exe_mode  => '0711',
            }
          END
        end

        it { is_expected.to contain_kmod__load('foo') }

        it do
          is_expected.to contain_file('/etc/modules-load.d/foo.conf').
            with(
              'owner' => 'adm',
              'group' => 'sys',
              'mode' => '0600'
            )
        end
      end
    end
  end
end
