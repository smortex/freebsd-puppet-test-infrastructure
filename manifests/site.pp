File {
  backup => false,
}

node default {
  include role::base
}

node 'puppet.lan' {
  include role::puppetserver
}

node 'puppetdb.lan' {
  include role::puppetdb
}
