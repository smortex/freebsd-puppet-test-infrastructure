# Choria broker configuration
class profile::choria::broker {
  include profile::choria::server

  class { 'choria::broker':
  }
}
