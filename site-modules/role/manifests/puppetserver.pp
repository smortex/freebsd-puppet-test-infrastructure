# @summary A role to manage the Puppet Server configuration
class role::puppetserver inherits role::base {
  include profile::choria::broker
  include profile::puppetserver
  include profile::r10k
}
