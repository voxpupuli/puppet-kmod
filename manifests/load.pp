define kmod::load (
  $ensure='present'
) {

  case $ensure {
    'present': {
      exec { "modprobe ${name}":
        unless => "egrep -q '^${name} ' /proc/modules",
      }

      augeas { "load module ${name} at boot":
        incl    => '/etc/modules',
        lens    => 'Modules.lns',
        changes => "ins '${name}' after *[last()]",
        onlyif  => "match '${name}' size == 0",
      }
    }

    'absent': {
      exec { "modprobe -r ${name}":
        onlyif => "egrep -q '^${name} ' /proc/modules",
      }

      augeas { "don't load module ${name} at boot":
        incl    => '/etc/modules',
        lens    => 'Modules.lns',
        changes => "rm '${name}'",
        onlyif  => "match '${name}' size > 0",
      }
    }
  }
}
