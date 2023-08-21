class profile::backup_home {
  include profile::bacula_client
  bacula::job { 'home':
    files => [
      '/usr/home'
    ],
  }
}
