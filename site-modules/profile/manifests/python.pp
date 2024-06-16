# @summary Manage Python
class profile::python {
  class { 'python':
    version => '311',
    dev     => 'present',
  }
}
