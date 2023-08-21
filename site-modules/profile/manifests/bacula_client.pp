class profile::bacula_client (
  String $director_name = 'node1.lan',
  String $address = $trusted['certname'],
) {
  $bacula_ssldir = '/usr/local/etc/bacula/ssl'

  $tls_ca_certificate_file = "${bacula_ssldir}/ca.pem"
  $tls_dh_file             = "${bacula_ssldir}/dh2048.pem"
  $tls_certificate_file    = "${bacula_ssldir}/${trusted['certname']}_crt.pem"
  $tls_key_file            = "${bacula_ssldir}/${trusted['certname']}_key.pem"

  file { $bacula_ssldir:
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    mode   => '0750',
  }

  file { $tls_ca_certificate_file:
    ensure  => present,
    owner   => 'root',
    group   => 'bacula',
    mode    => '0644',
    source  => 'file:///var/puppet/ssl/certs/ca.pem',
  }

  file { $tls_certificate_file:
    ensure  => present,
    owner   => 'root',
    group   => 'bacula',
    mode    => '0644',
    source  => "file:///var/puppet/ssl/certs/${trusted['certname']}.pem",
  }

  file { $tls_key_file:
    ensure  => present,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0440',
    source  => "file:///var/puppet/ssl/private_keys/${trusted['certname']}.pem",
  }

  exec { 'bacula-dhparams':
    command  => "openssl dhparam -out ${tls_dh_file} -5 2048",
    path     => '/usr/bin',
    creates  => $tls_dh_file,
    provider => 'shell',
    require  => File[$bacula_ssldir],
  }

  $pki_key     = "${bacula_ssldir}/${trusted['certname']}_pki_key.pem"
  $pki_crt     = "${bacula_ssldir}/${trusted['certname']}_pki_crt.pem"
  $pki_crt_key = "${bacula_ssldir}/${trusted['certname']}_pki_crt+key.pem"

  exec { 'generate-bacula-pki-key':
    command  => "umask 077 && openssl genrsa -out ${pki_key} 4096",
    path     => '/usr/bin',
    creates  => $pki_key,
    provider => 'shell',
    require  => File[$bacula_ssldir],
  }
  -> exec { 'generate-bacula-pki-crt':
    command => "openssl req -new -x509 -key ${pki_key} -out ${pki_crt} -days 3650 -subj /CN=${trusted['certname']}",
    path    => '/usr/bin',
    creates => $pki_crt,
  }
  -> concat { $pki_crt_key:
    ensure => present,
    owner  => 'root',
    group  => 'bacula',
    mode   => '0440',
  }

  concat::fragment { 'bacula-pki-crt':
    target => $pki_crt_key,
    source => $pki_crt,
    order  => '10',
  }

  concat::fragment { 'bacula-pki-key':
    target => $pki_crt_key,
    source => $pki_key,
    order  => '20',
  }

  class { 'bacula':
    storage_name            => $director_name,
    director_name           => $director_name,
    director_address        => $director_name,
    tls_enable              => 'yes',
    tls_require             => 'yes',
    tls_verify_peer         => 'yes',
    tls_ca_certificate_file => $tls_ca_certificate_file,
    tls_dh_file             => $tls_dh_file,
    tls_certificate         => $tls_certificate_file,
    tls_key                 => $tls_key_file,
  }

  class { 'bacula::client':
    client         => $trusted['certname'],
    address        => $address,
    listen_address => [
      '::',
    ],

    director_name  => $director_name,
    password       => 'secret',

    pki_encryption => true,
    pki_signatures => true,
    pki_keypair    => $pki_crt_key,
  }

  File[
    $tls_ca_certificate_file,
    $tls_certificate_file,
    $tls_key_file,
  ] ~> Service[$bacula::client::services]
}
