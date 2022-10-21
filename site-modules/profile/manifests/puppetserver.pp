# @summary Manage Puppet Server
#
# This profile does not manage the whole Puppet Server configuration.
class profile::puppetserver {
  service { 'puppetserver':
    ensure => running,
    enable => true,
  }
}
