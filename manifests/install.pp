define kmod::install(
  $ensure=present,
  $command='/bin/true',
  $file=''
) {
  kmod::generic {"install ${name}":
    ensure   => $ensure,
    type     => 'install',
    module   => $name,
    command  => $command,
    file     => $file,
  }
}
