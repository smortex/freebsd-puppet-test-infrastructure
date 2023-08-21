class profile::bacula_server {
  include profile::bacula_client
  include profile::postgresql

  class { 'bacula::director':
    listen_address => [
      '::',
    ],
  }

  class { 'bacula::storage':
    listen_address => [
      '::',
    ],
    storage        => $trusted['certname'],
    address        => $trusted['certname'],
  }
}
