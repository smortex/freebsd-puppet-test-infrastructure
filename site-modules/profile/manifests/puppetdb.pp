# @summary Manage the PuppetDB service
#
# This profile does not manage the whole PuppetDB configuration.
class profile::puppetdb {
  service { 'puppetdb':
    ensure => running,
    enable => true,
  }
}
