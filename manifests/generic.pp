define kmod::generic(
  $type,
  $module,
  $ensure=present,
  $command='',
  $file=''
) {

  $filepath = $file ? {
    ''      => '/etc/modprobe.d/modprobe.conf',
    default => $file,
  }

  case $ensure {
    present: {
      exec {"modprobe ${module}":
        unless => "egrep -q '^${module} ' /proc/modules",
      }
      
      if $command {
        augeas {"${type} module ${module}":
          context => "/files${filepath}",
          changes => [
                "set ${type}[. = '${module}'] ${module}",
                "set ${type}[. = '${module}']/command '${command}'",
                ],
        }
      } else {
        augeas {"${type} module ${module}":
          context => "/files${filepath}",
          changes => [ "set ${type}[. = '${module}'] ${module}" ],
        }
  
      }
    }

    absent: {
      exec {"modprobe -r ${module}": 
        onlyif => "egrep -q '^${module} ' /proc/modules",
      }

      augeas {"remove module ${module}":
        context => "/files${filepath}",
        changes => "rm ${type}[. = '${module}']",
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }

}
