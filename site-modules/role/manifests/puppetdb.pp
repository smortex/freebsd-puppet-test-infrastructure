# @summary A role to manage PuppetDB
class role::puppetdb inherits role::base {
  include profile::puppetdb
}
