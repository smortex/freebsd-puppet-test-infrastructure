class profile::puppetserver {
  service { 'puppetserver':
    ensure => running,
    enable => true,
  }
}
