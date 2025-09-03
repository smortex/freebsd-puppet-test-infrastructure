# @summary Setup PuppetBoard
#
# @param port The port the service listen on
class profile::puppetboard (
  Stdlib::Port $port = 8000,
) {
  $python_version = '311'

  file {
    default:
      ensure => directory,
      owner  => 'root',
      group  => 'wheel',
      mode   => '0755',
      before => Service['puppetboard'],
      ;
    '/usr/local/etc/puppetboard/ssl':
      ;
    '/usr/local/etc/puppetboard/ssl/ca.pem':
      ensure => file,
      mode   => '0644',
      source => '/var/puppet/ssl/certs/ca.pem',
      ;
    '/usr/local/etc/puppetboard/ssl/puppetdb_client_cert.pem':
      ensure => file,
      mode   => '0644',
      source => "/var/puppet/ssl/certs/${fact('networking.fqdn')}.pem",
      ;
    '/usr/local/etc/puppetboard/ssl/puppetdb_client_key.pem':
      ensure => file,
      group  => 'puppetboard',
      mode   => '0640',
      source => "/var/puppet/ssl/private_keys/${fact('networking.fqdn')}.pem",
      ;
    '/var/log/puppetboard':
      owner => 'puppetboard',
      group => 'puppetboard',
      ;
    '/var/run/puppetboard':
      owner => 'puppetboard',
      group => 'puppetboard',
      ;
    '/usr/local/etc/rc.d/puppetboard':
      ensure  => file,
      mode    => '0755',
      content => epp('profile/puppetboard/puppetboard.rc.epp'),
      ;
  }

  class { 'puppetboard':
    package_name        => "py${python_version}-puppetboard",
    secret_key          => stdlib::fqdn_rand_string(32),
    puppetdb_host       => 'puppetdb.lan',
    puppetdb_port       => 8081,
    puppetdb_cert       => '/usr/local/etc/puppetboard/ssl/puppetdb_client_cert.pem',
    puppetdb_key        => '/usr/local/etc/puppetboard/ssl/puppetdb_client_key.pem',
    puppetdb_ssl_verify => '/usr/local/etc/puppetboard/ssl/ca.pem',
    offline_mode        => true,
    notify              => Service['puppetboard'],
  }

  package { "uwsgi-py${python_version}":
    ensure => installed,
  }

  service { 'puppetboard':
    ensure => running,
    enable => true,
  }
}
