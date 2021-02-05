class profile::r10k {
  user { 'r10k':
    ensure     => present,
    system     => true,
    groups     => [
      'puppet',
    ],
    home       => '/home/r10k',
    managehome => true,
  }

  package { 'rubygem-r10k':
    ensure => installed,
  }

  file { '/usr/local/etc/r10k/r10k.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    content => @(R10K),
      # The location to use for storing cached Git repos
      :cachedir: '/var/puppet/r10k/cache'

      # A list of git repositories to create
      :sources:
        # This will clone the git repository and instantiate an environment per
        # branch in /usr/local/etc/puppet/code/environments
        :code:
          remote: 'https://github.com/smortex/freebsd-puppet-test-infrastructure.git'
          basedir: '/usr/local/etc/puppet/code/environments'
      | R10K
  }
}
