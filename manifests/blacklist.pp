define kmod::blacklist(
  $ensure=present,
  $file=''
) {
  kmod::generic {"blacklist ${name}":
    ensure  => $ensure,
    type    => 'blacklist',
    module  => $name,
    file    => $file,
  }
}
