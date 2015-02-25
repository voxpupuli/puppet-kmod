# = Define: kmod::setting
#
# == Example
#
#
define kmod::setting(
  $file,
  $category,
  $option = undef,
  $value = undef,
  $module = $name,
  $ensure = 'present',
) {

  include ::kmod

  ensure_resource('file', $file, { 'ensure' => 'file'} )
  case $ensure {
    'present': {
      if $option {
        $augset = [
          "set ${category}[. = '${module}'] ${module}",
          "set ${category}[. = '${module}']/${option} ${value}",
        ]
      } else {
        $augset = [
          "set ${category}[. = '${module}'] ${module}",
        ]
      }

      $onlyif = "match ${category}[. = '${module}'] size == 0"


      augeas { "kmod::setting ${title} ${module}":
        incl    => $file,
        lens    => 'Modprobe.lns',
        changes => $augset,
        onlyif  => $onlyif,
        require => File[$file],
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
