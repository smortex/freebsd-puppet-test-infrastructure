class profile::postgresql {
  class { 'postgresql::globals':
    version => '13',
  }

  class { 'postgresql::server':
  }
}
