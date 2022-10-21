# @summary Manage the Puppet service
#
# This profile does not manage the whole Puppet configuration.
class profile::puppet {
  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
