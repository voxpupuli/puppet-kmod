#
# == Fact: kmod_update_initrd_cmd
#
# Determine which command (if any) must be run to regenerate the initramfs
# image file for the currently-running kernel.
require 'facter'

#
# Function that behaves similarly to the "which" command.
#
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

#
# Use dracut if it is available,
# or update-initramfs if it exists,
# or else return nil.
#
Facter.add(:kmod_update_initrd_cmd) do
  confine Facter.value(:kernel)=> 'Linux'
  setcode do
    cmd = which('dracut')
    if cmd.nil? then
      cmd = which('update-initramfs')
      if cmd.nil? then
        nil
      else
        "#{cmd} -u"
      end
    else
      "#{cmd} -H f"
    end
  end
end
