# @summary Configure bacula director and storage
class role::backupserver inherits role::base {
  include profile::bacula_server
}
