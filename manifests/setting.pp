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

  kmod_setting { $title:
    ensure   => $ensure,
    name     => $module,
    target   => $file,
    category => $category,
    option   => $option,
    value    => $value,
  }
}
