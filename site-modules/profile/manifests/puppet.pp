class profile::puppet {
  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
