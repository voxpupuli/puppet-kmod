require 'spec_helper'

describe 'kmod::alias', :type => :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:default_params) do { :source => 'bar', :file => '/baz' } end

      context 'when ensure is set to present' do
        let(:params) do default_params end
        it { should contain_kmod__alias('foo') }
        it { should contain_augeas('modprobe alias foo bar').with({
          'incl'    => '/baz',
          'lens'    => 'Modprobe.lns',
          'changes' => [ "set alias[. = 'foo'] foo","set alias[. = 'foo']/modulename bar" ],
          'onlyif'  => "match alias[. = 'foo'] size == 0",
          'require' => 'File[/baz]'
        }) }
      end

      context 'when ensure is set to absent' do
        let(:params) do
          default_params.merge!({ :ensure => 'absent' })
        end
        it { should contain_kmod__alias('foo') }
        it { should contain_kmod__load('foo').with({ 'ensure' => 'absent' }) }
        it { should contain_augeas('remove modprobe alias foo').with({
          'incl'    => '/baz',
          'lens'    => 'Modprobe.lns',
          'changes' => "rm alias[. = 'foo']",
          'onlyif'  => "match alias[. = 'foo'] size > 0",
          'require' => 'File[/baz]'
        }) }
      end
    end
  end
end
