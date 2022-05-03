# frozen_string_literal: true

require 'spec_helper'

describe 'kmod::option', type: :define do
  let(:title) { 'foo' }
  let(:default_params) do
    {
      'module' => 'bond0',
      'option' => 'mode',
      'value' => '1',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(augeasversion: '1.2.0') }
      let(:params) { default_params }

      context 'when ensure is default (present)' do
        it { is_expected.to compile }
        it { is_expected.to contain_kmod__option(title).with(params) }

        it do
          is_expected.to contain_kmod__setting("kmod::option #{title}").
            with_ensure('present').
            with_module(params['module']).
            with_category('options').
            with_file("/etc/modprobe.d/#{params['module']}.conf").
            with_option(params['option']).
            with_value(params['value'])
        end
      end

      context 'when file permissions are specified' do
        let(:params) { default_params }
        let(:pre_condition) do
          <<~END
            class { 'kmod':
              owner     => 'adm',
              group     => 'sys',
              file_mode => '0600',
            }
          END
        end

        it { is_expected.to contain_kmod__option(title) }

        it {
          is_expected.to contain_file("/etc/modprobe.d/#{params['module']}.conf").
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
