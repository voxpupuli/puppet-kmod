#
# == Fact: kmod_update_initrd_cmd
#
# Determine which command (if any) must be run to regenerate the initramfs
# image file for the currently-running kernel.
#
# Use update-initramfs if it is availble,
# else use dracut if it is available,
# else return nil.
#
Facter.add(:kmod_update_initrd_cmd) do
  setcode do
    cmd = Facter::Util::Resolution.which('update-initramfs')
    if cmd.nil?
      cmd = Facter::Util::Resolution.which('dracut')
      unless cmd.nil?
        "#{cmd} -H -f"
      end
    else
      "#{cmd} -u"
    end
  end
end
