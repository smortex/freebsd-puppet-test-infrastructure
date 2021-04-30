class profile::puppetdb {
  service { 'puppetdb':
    ensure => running,
    enable => true,
  }
}
