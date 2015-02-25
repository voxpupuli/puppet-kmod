# = Define: kmod::alias
#
# == Example
#
#     kmod::alias { 'bond0':
#       alias => 'bonding',
#     }
#
define kmod::alias(
  $modulename,
  $ensure     = 'present',
  $file       = "/etc/modprobe.d/${title}.conf",
  $aliasname  = $title,
) {

  include ::kmod

  kmod::setting { "kmod::alias ${title}":
    module   => $aliasname,
    file     => $file,
    category => 'alias',
    option   => 'modulename',
    value    => $modulename,
  }

}
