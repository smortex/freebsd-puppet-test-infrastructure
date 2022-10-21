# @summary Base configuration we want to see on all nodes
class profile::baseline {
  user { 'freebsd':
    ensure         => present,
    home           => '/home/freebsd',
    managehome     => true,
    password       => '*',
    purge_ssh_keys => true,
    shell          => '/bin/tcsh',
  }

  ssh_authorized_key { 'romain@fenchurch':
    ensure => present,
    user   => 'freebsd',
    type   => 'ssh-ed25519',
    key    => 'AAAAC3NzaC1lZDI1NTE5AAAAILvGP9clA62A6cTrc68sqRp1m2MWVrpBy1EigRnMpSfG',
  }

  ssh_authorized_key { 'romain@zappy':
    ensure => present,
    user   => 'freebsd',
    type   => 'ssh-ed25519',
    key    => 'AAAAC3NzaC1lZDI1NTE5AAAAIA6yVrhynggRJukkYA/QBXo8ZaplMOQV+/4yNWtxu2LJ',
  }
}
