user { 'r10k':
  ensure   => present,
  password => '*',
  groups   => [
    'puppet',
  ],
}

package { 'git-lite':
  ensure => installed,
}

package { 'rubygem-r10k':
  ensure => installed,
}

file { '/usr/local/etc/r10k':
  ensure => directory,
  owner  => 'root',
  group  => 'wheel',
  mode   => '0755',
}

file { '/usr/local/etc/r10k/r10k.yaml':
  ensure  => file,
  owner   => 'root',
  group   => 'wheel',
  mode    => '0644',
  content => @(YAML),
    # The location to use for storing cached Git repos
    :cachedir: '/var/puppet/r10k/cache'
    
    # A list of git repositories to create
    :sources:
      # This will clone the git repository and instantiate an environment per
      # branch in /usr/local/etc/puppet/code/environments
      :code:
        remote: 'https://github.com/smortex/freebsd-puppet-test-infrastructure.git'
        basedir: '/usr/local/etc/puppet/code/environments'
    | YAML
}

file { '/var/puppet/r10k':
  ensure => directory,
  owner  => 'r10k',
  group  => 'r10k',
  mode   => '0755',
}

file { '/var/puppet/r10k/cache':
  ensure => directory,
  owner  => 'r10k',
  group  => 'r10k',
  mode   => '0755',
}

file { '/usr/local/etc/puppet/code/environments':
  ensure => directory,
  owner  => 'r10k',
  group  => 'puppet',
  mode   => '0750',
}

exec { '/usr/local/bin/r10k deploy environment -vp':
  user => 'r10k',
}
