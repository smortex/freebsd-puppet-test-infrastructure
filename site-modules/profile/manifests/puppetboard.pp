# @summary Setup PuppetBoard
#
# @param port The port the service listen on
class profile::puppetboard (
  Stdlib::Port $port = 8000,
) {
  class { 'puppetboard':
    puppetdb_host       => 'puppetdb.lan',
    puppetdb_port       => 8081,
    puppetdb_cert       => '/usr/local/www/puppetboard/ssl/puppetdb_client_cert.pem',
    puppetdb_key        => '/usr/local/www/puppetboard/ssl/puppetdb_client_key.pem',
    puppetdb_ssl_verify => '/usr/local/www/puppetboard/ssl/ca.pem',
    offline_mode        => true,
  }

  file { '/usr/local/www/puppetboard/ssl':
    ensure => directory,
    owner  => 'root',
    group  => 'puppetboard',
    mode   => '0755',
  }

  file { '/usr/local/www/puppetboard/ssl/ca.pem':
    ensure => file,
    owner  => 'root',
    group  => 'puppetboard',
    mode   => '0644',
    source => '/var/puppet/ssl/certs/ca.pem',
  }

  file { '/usr/local/www/puppetboard/ssl/puppetdb_client_cert.pem':
    ensure => file,
    owner  => 'root',
    group  => 'puppetboard',
    mode   => '0640',
    source => "/var/puppet/ssl/certs/${fact('networking.fqdn')}.pem",
  }

  file { '/usr/local/www/puppetboard/ssl/puppetdb_client_key.pem':
    ensure => file,
    owner  => 'root',
    group  => 'puppetboard',
    mode   => '0640',
    source => "/var/puppet/ssl/private_keys/${fact('networking.fqdn')}.pem",
  }

  package { 'uwsgi-py39':
    ensure => installed,
  }

  file { '/var/run/puppetboard':
    ensure => directory,
    owner  => 'puppetboard',
    group  => 'puppetboard',
    mode   => '0755',
  }

  file { '/usr/local/etc/rc.d/puppetboard':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0755',
    content => epp('profile/puppetboard/puppetboard.rc.epp'),
  }

  service { 'puppetboard':
    ensure => running,
    enable => true,
  }
}
