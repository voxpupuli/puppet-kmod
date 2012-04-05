define kmod::install($ensure=present, $command='/bin/true') {

  case $ensure {
    present: {
      exec {"modprobe ${name}":
        unless => "egrep -q '^${name} ' /proc/modules",
      }
      
      augeas {"install module ${name}":
        context => '/files/etc/modprobe.d/modprobe.conf',
        changes => [
          "set /install[. = '${name}'] ${name}",
          "set /install[. = '${name}']/command '${command}'",
        ],
      }
    }

    absent: {
      exec {"modprobe -r ${name}": 
        onlyif => "egrep -q '^${name} ' /proc/modules",
      }

      augeas {"remove module ${name}":
        context => '/files/etc/modprobe.d/modprobe.conf',
        changes => "rm /install[. = '${name}']",
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }

}
