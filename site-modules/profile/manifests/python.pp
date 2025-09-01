# @summary Manage Python
class profile::python (
  Integer[0] $major = 3,
  Integer[0] $minor = 11,
) {
  class { 'python':
    version => "${major}${minor}",
    dev     => 'present',
  }
}
