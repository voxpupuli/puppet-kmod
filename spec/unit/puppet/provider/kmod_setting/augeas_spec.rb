#!/usr/bin/env rspec

require 'spec_helper'

provider = :augeas
provider_class = Puppet::Type.type(:kmod_setting).provider(provider)

describe provider_class do
  context "with empty file" do
    let(:tmptarget) { aug_fixture("empty") }
    let(:target) { tmptarget.path }

    it "should create simple new entry" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :ensure   => "present",
        :name     => "usbmouse",
        :category => "blacklist",
        :target   => target,
        :provider => provider,
      ))

      augparse(target, "Modprobe.lns", '
        { "blacklist" = "usbmouse" }
      ')
    end

    it "should create new entry with option" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :ensure   => "present",
        :name     => "bonding",
        :category => "alias",
        :option   => "modulename",
        :value    => "off",
        :target   => target,
        :provider => provider,
      ))

      augparse(target, "Modprobe.lns", '
        { "alias" = "bonding"
          { "modulename" = "off" } }
      ')
    end
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    it "should list instances" do
      provider_class.stubs(:target).returns(target)
      inst = provider_class.instances.map { |p|
        {
          :name => p.get(:name),
          :ensure => p.get(:ensure),
          :value => p.get(:value),
        }
      }

      expect(inst.size).to eq(30)
      expect(inst[0]).to eq({:ensure=>:present, :name=>"sound-slot-0", :value=>"/sbin/modprobe snd-card-0"})
    end

    it "should create simple new entry" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :ensure   => "present",
        :name     => "usbmouse",
        :category => "blacklist",
        :target   => target,
        :provider => provider,
      ))

      augparse_filter(target, "Modprobe.lns", "blacklist", '
        { "blacklist" = "usbmouse" }
      ')
    end

    it "should create new entry with option" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :ensure   => "present",
        :name     => "bonding",
        :category => "alias",
        :option   => "modulename",
        :value    => "off",
        :target   => target,
        :provider => provider,
      ))

      augparse_filter(target, "Modprobe.lns", "alias", '
        { "alias" = "bonding"
          { "modulename" = "off" } }
      ')
    end

    it "should update existing entry" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :name     => "bt87x",
        :category => "options",
        :option   => "index",
        :value    => "42",
        :target   => target,
        :provider => provider,
      ))

      aug_open(target, "Modprobe.lns") do |aug|
        aug.get("options[.='bt87x']/index").should eq "42"
      end
    end

    it "should remove existing entry entirely" do
      apply!(Puppet::Type.type(:kmod_setting).new(
        :name     => "bt87x",
        :category => "options",
        :ensure   => "absent",
        :target   => target,
        :provider => provider,
      ))

      aug_open(target, "Modprobe.lns") do |aug|
        aug.match("options[.='bt87x']").size.should eq 0
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      txn = apply(Puppet::Type.type(:kmod_setting).new(
        :name     => "bt87x",
        :category => "options",
        :target   => target,
        :provider => provider,
      ))

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end

