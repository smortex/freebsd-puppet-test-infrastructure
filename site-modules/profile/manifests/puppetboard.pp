class profile::puppetboard {
  class { 'puppetboard':
    puppetdb_host       => 'puppetdb.lan',
    puppetdb_port       => 8081,
    puppetdb_cert       => '/usr/local/www/puppetboard/ssl/puppetdb_client_cert.pem',
    puppetdb_key        => '/usr/local/www/puppetboard/ssl/puppetdb_client_key.pem',
    puppetdb_ssl_verify => '/usr/local/www/puppetboard/ssl/ca.pem',
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

  package { 'uwsgi':
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
    content => @(RC),
      #!/bin/sh
      # PROVIDE: puppetboard
      # REQUIRE: LOGIN
      # KEYWORD: shutdown

      . /etc/rc.subr

      name="puppetboard"
      rcvar=puppetboard_enable
      pidfile="/var/run/${name}/${name}.pid"

      load_rc_config "$name"

      : ${puppetboard_enable="NO"}
      : ${puppetboard_user="puppetboard"}
      : ${puppetboard_options="--http :8000 --wsgi-file /usr/local/www/puppetboard/wsgi.py"}

      command=/usr/local/bin/uwsgi
      command_args="--master --daemonize ${pidfile} --die-on-term --pidfile ${pidfile} ${puppetboard_options}"

      run_rc_command "$1"
      | RC
  }

  service { 'puppetboard':
    ensure => running,
    enable => true,
  }
}
