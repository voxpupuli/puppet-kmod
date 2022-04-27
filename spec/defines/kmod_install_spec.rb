# frozen_string_literal: true

require 'spec_helper'

describe 'kmod::install', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(augeasversion: '1.2.0')
      end

      let(:params) { { ensure: 'present', command: '/bin/true', file: '/etc/modprobe.d/foo.conf' } }

      context 'when ensure is set to present' do
        it { is_expected.to contain_kmod__install('foo') }

        it {
          is_expected.to contain_kmod__setting('kmod::install foo').
            with('ensure' => 'present',
                 'category' => 'install',
                 'module' => 'foo',
                 'option' => 'command',
                 'value' => '/bin/true',
                 'file' => '/etc/modprobe.d/foo.conf')
        }
      end

      context 'when file permissions are specified' do
        let(:pre_condition) do
          <<~END
            class { 'kmod':
              owner     => 'adm',
              group     => 'sys',
              file_mode => '0600',
            }
          END
        end

        it { is_expected.to contain_kmod__install('foo') }

        it {
          is_expected.to contain_file(params[:file]).
            with(
              'owner' => 'adm',
              'group' => 'sys',
              'mode' => '0600'
            )
        }
      end
    end
  end
end
