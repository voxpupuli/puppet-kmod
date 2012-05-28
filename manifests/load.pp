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
      $changes = "clear ${name}"
    }

    absent: {
      $changes = "rm ${name}"
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }

  augeas {"Manage ${name} in ${file}":
    context => "/files${file}",
    changes => $changes,
  }
}
