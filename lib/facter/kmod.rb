# frozen_string_literal: true

# @summary Return a hash of loaded kernel modules explicitly declared by puppet
#  e.g. using kmod::load { 'overlay': }

def kmod_load_module_config(kmodule)
  if File.exist?('/sys/module')
    config = {
      'parameters' => {},
      'used_by' => [],
    }

    if File.directory?("/sys/module/#{kmodule}/parameters")
      Dir.foreach("/sys/module/#{kmodule}/parameters") do |param|
        next if ['.', '..'].include?(param)

        next unless File.readable?("/sys/module/#{kmodule}/parameters/#{param}")

        begin
          config['parameters'][param] = File.read("/sys/module/#{kmodule}/parameters/#{param}").chomp.delete("\u0000")
        rescue StandardError
          # some kernel parameters are write only
          # even though they have the read bit set
          # so just ignore read errors
          nil
        end
      end
    end

    if File.directory?("/sys/module/#{kmodule}/holders")
      Dir.foreach("/sys/module/#{kmodule}/holders") do |used|
        next if ['.', '..'].include?(used)

        config['used_by'] << used
      end
    end

    config
  else
    Facter.debug('/sys/module is not found. skipping.')
  end
end

Facter.add(:kmods) do
  confine kernel: :linux

  kmod = {}

  setcode do
    if File.directory?('/etc/modules-load.d')
      # Debian
      Dir.foreach('/etc/modules-load.d') do |item|
        next if ['.', '..', 'modules.conf'].include?(item)

        if item.end_with? '.conf'
          mod = File.basename(item, '.conf')
          kmod[mod] = kmod_load_module_config(mod)
        end
      end
    elsif File.directory?('/etc/sysconfig/modules')
      # RedHat
      Dir.foreach('/etc/sysconfig/modules') do |item|
        next if ['.', '..'].include?(item)

        if item.end_with? '.modules'
          mod = File.basename(item, '.modules')
          kmod[mod] = kmod_load_module_config(mod)
        end
      end
    end
    kmod
  end
end
