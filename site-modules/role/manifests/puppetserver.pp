class role::puppetserver inherits role::base {
  include profile::r10k
  include profile::choria::broker
}
