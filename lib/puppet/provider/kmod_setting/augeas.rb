# Alternative Augeas-based provider for nrpe type
#
# Copyright (c) 2019 Camptocamp
# Licensed under the Apache License, Version 2.0

raise("Missing augeasproviders_core dependency") if Puppet::Type.type(:augeasprovider).nil?
Puppet::Type.type(:kmod_setting).provide(:augeas, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas API to update kmod settings."

  default_file { '/etc/modprobe.conf' }

  lens { 'Modprobe.lns' }

  confine :feature => :augeas

  resource_path do |resource|
    "$target/#{resource[:category]}[.='#{resource[:name]}']"
  end

  def self.instances
    augopen do |aug|
      aug.match("$target/*[label()!='#comment']").map do |spath|
        options = aug.match("#{spath}/*")
        if options.empty?
            option = nil
            value = nil
        else
            option = path_label(aug, options[0])
            value = aug.get(options[0])
        end
        new({
          :ensure   => :present,
          :category => path_label(aug, spath),
          :name     => aug.get(spath),
          :option   => option,
          :value    => value,
        })
      end
    end
  end

  define_aug_method!(:create) do |aug, resource|
    aug.defnode('resource', resource_path(resource), resource[:name])
    resource.provider.value = resource[:value]
  end

  define_aug_method(:value) do |aug, resource|
    option = resource[:option]
    unless option.nil?
      option_path = "$resource/#{option}"
      unless aug.match(option_path).empty?
        aug.get(option_path)
      end
    end
  end

  define_aug_method!(:value=) do |aug, resource, value|
    unless value.nil?
      option = resource[:option]
      unless option.nil?
        option_path = "$resource/#{option}"
        aug.set(option_path, value)
      end
    end
  end
end
