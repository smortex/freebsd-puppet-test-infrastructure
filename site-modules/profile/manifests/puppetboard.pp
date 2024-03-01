# @summary Setup PuppetBoard
#
# @param port The port the service listen on
class profile::puppetboard (
  Stdlib::Port $port = 8000,
) {
  include profile::python

  file {
    default:
      owner  => 'root',
      group  => 'wheel',
      before => Service['puppetboard'],
      ;
    '/usr/local/etc/puppetboard':
      ensure => directory,
      mode   => '0755',
      ;
    '/usr/local/www':
      ensure => directory,
      group  => 'puppetboard',
      mode   => '0755',
      ;
    '/usr/local/www/puppetboard/ssl':
      ensure => directory,
      mode   => '0755',
      ;
    '/usr/local/www/puppetboard/ssl/ca.pem':
      ensure => file,
      group  => 'wheel',
      mode   => '0644',
      source => '/var/puppet/ssl/certs/ca.pem',
      ;
    '/usr/local/www/puppetboard/ssl/puppetdb_client_cert.pem':
      ensure => file,
      group  => 'wheel',
      mode   => '0644',
      source => "/var/puppet/ssl/certs/${fact('networking.fqdn')}.pem",
      ;
    '/usr/local/www/puppetboard/ssl/puppetdb_client_key.pem':
      ensure => file,
      group  => 'puppetboard',
      mode   => '0640',
      source => "/var/puppet/ssl/private_keys/${fact('networking.fqdn')}.pem",
      ;
    '/var/run/puppetboard':
      ensure => directory,
      owner  => 'puppetboard',
      group  => 'puppetboard',
      mode   => '0755',
      ;
    '/usr/local/etc/rc.d/puppetboard':
      ensure  => file,
      group   => 'wheel',
      mode    => '0755',
      content => epp('profile/puppetboard/puppetboard.rc.epp'),
      ;
  }

  class { 'puppetboard':
    install_from        => 'pip',
    python_version      => '3.9',
    basedir             => '/usr/local/www/puppetboard',
    secret_key          => stdlib::fqdn_rand_string(32),
    puppetdb_host       => 'puppetdb.lan',
    puppetdb_port       => 8081,
    puppetdb_cert       => '/usr/local/www/puppetboard/ssl/puppetdb_client_cert.pem',
    puppetdb_key        => '/usr/local/www/puppetboard/ssl/puppetdb_client_key.pem',
    puppetdb_ssl_verify => '/usr/local/www/puppetboard/ssl/ca.pem',
    offline_mode        => true,
    notify              => Service['puppetboard'],
  }

  file { '/usr/local/www/puppetboard/wsgi.py':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    content => @(WSGI),
      from __future__ import absolute_import
      import os
      import logging

      logging.basicConfig(filename='/tmp/puppetboard.log', level=logging.DEBUG)

      os.environ['PUPPETBOARD_SETTINGS'] = '/usr/local/etc/puppetboard/settings.py'

      try:
          from puppetboard.app import app as application  # noqa: F401
      except Exception as inst:
          logging.exception("Error: %s", str(type(inst)))
      | WSGI
    notify  => Service['puppetboard'],
  }

  package { 'uwsgi-py39':
    ensure => installed,
  }

  service { 'puppetboard':
    ensure => running,
    enable => true,
  }
}
