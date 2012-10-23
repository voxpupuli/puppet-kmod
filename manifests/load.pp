/*

== Definition: kmod::load

Manage a kernel module in /etc/modules.

Parameters:
- *ensure*: present/absent;
- *file*: optionally, set the file where the stanza is written.

Example usage:

  kmod::load { 'sha256': }

*/

define kmod::load(
  $ensure=present,
  $file='/etc/modules'
) {

  case $ensure {
    present: {
      $changes = "clear '${name}'"

      exec { "modprobe ${name}":
        unless => "egrep -q '^${name} ' /proc/modules",
      }
    }

    absent: {
      $changes = "rm '${name}'"

      exec { "modprobe -r ${name}":
        onlyif => "egrep -q '^${name} ' /proc/modules",
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }

  augeas {"Manage ${name} in ${file}":
    incl    => $file,
    lens    => 'Modules.lns',
    changes => $changes,
  }
}
