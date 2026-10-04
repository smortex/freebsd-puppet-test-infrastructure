# @summary Manage Python
#
# @param major Python major version
# @param minor Python minor version
class profile::python (
  Integer[0] $major = 3,
  Integer[0] $minor = 12,
) {
  class { 'python':
    version => "${major}${minor}",
    dev     => 'present',
  }
}
