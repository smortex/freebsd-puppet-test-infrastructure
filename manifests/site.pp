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

node 'puppetboard.lan' {
  include role::puppetboard
}

node 'node1.lan' {
  include role::backupserver
}

node 'node2.lan' {
  include role::backupclient
}
