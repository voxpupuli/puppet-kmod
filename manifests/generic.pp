/*

== Definition: kmod::generic

Set a kernel module in modprobe.conf (5).

Parameters:
- *type*: type of modprobe stanza (install/blacklist/etc);
- *module*: module name;
- *ensure*: present/absent;
- *command*: optionally, set the command associated with the kernel module;
- *file*: optionally, set the file where the stanza is written.

Example usage:

  kmod::generic {'install pcspkr':
    type   => 'install',
    module => 'pcspkr',
  }

*/

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
          onlyif  => "match ${type}[. = '${module}'] size == 0",
        }
      } else {
        augeas {"${type} module ${module}":
          context => "/files${filepath}",
          changes => [ "set ${type}[. = '${module}'] ${module}" ],
          onlyif  => "match ${type}[. = '${module}'] size == 0",
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
        onlyif  => "match ${type}[. = '${module}'] size > 0",
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
