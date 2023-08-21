# @summary Configure bacula client
class role::backupclient inherits role::base {
  include profile::bacula_client
  include profile::backup_home
}
