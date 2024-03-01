# @summary Manage Python
class profile::python {
  class { 'python':
    version => '39',
    dev     => 'present',
  }
}
