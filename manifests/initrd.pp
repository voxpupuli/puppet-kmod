#
# == Class: kmod::initrd
#
# Reconfigures the initramfs image after modifying kernel module configuration.
#
#
class kmod::initrd(Optional[String] $cmd = $facts.kmod_update_initrd_cmd){
  if defined($cmd) {
    exec { 'Update initramfs image.':
      command     => $cmd,
      refreshonly => true,
      subscribe   => [
        Class['kmod::alias'],
        Class['kmod::blacklist'],
        Class['kmod::install'],
        Class['kmod::load'],
        Class['kmod::option'],
      ],
    }
  }
}
