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
  $file
) {

  case $ensure {
    present: {
      if $type == 'install' {
        exec {"modprobe ${module}":
          unless => "egrep -q '^${module} ' /proc/modules",
        }
      }

      if $command {
        # modprobe.conf usage changes in 0.10.0
        if versioncmp($augeasversion, '0.9.0') < 0 {
          $augset = "set ${type}[. = '${module}'] '${module} ${command}'"
          $onlyif = "match ${type}[. = '${module} ${command}'] size == 0"
        } else {
          $augset = [
            "set ${type}[. = '${module}'] ${module}",
            "set ${type}[. = '${module}']/command '${command}'",
          ]
          $onlyif = "match ${type}[. = '${module}'] size == 0"
        }
      } else {
        $augset = "set ${type}[. = '${module}'] ${module}"
      }

      augeas {"${type} module ${module}":
        context => "/files${file}",
        changes => $augset,
        onlyif  => $onlyif,
      }
    }

    absent: {
      exec {"modprobe -r ${module}":
        onlyif => "egrep -q '^${module} ' /proc/modules",
      }

      augeas {"remove module ${module}":
        context => "/files${file}",
        changes => "rm ${type}[. = '${module}']",
        onlyif  => "match ${type}[. = '${module}'] size > 0",
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
