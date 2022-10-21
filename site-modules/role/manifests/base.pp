# @summary A base role any node should have
class role::base {
  include profile::baseline
  include profile::choria::server
  include profile::puppet
}
