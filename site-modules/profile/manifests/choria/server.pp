# @summary Manage choria server configuration
#
# @param client Also manange client configuration
class profile::choria::server (
  Boolean $client = false,
) {
  class { 'choria':
    server             => true,
    broker_logfile     => '/var/log/choria-broker.log',
    server_logfile     => '/var/log/choria-server.log',
    manage_mcollective => false,
  }

  class { 'mcollective':
    client         => $client,
    plugin_classes => [
      'mcollective_agent_bolt_tasks',
      'mcollective_agent_filemgr',
      'mcollective_agent_nettest',
      'mcollective_agent_package',
      'mcollective_agent_puppet',
      'mcollective_agent_service',
      'mcollective_choria',
      'mcollective_util_actionpolicy',
    ],
    site_policies  => [
      {
        action  => 'allow',
        callers => 'choria=freebsd.mcollective',
        actions => '*',
        facts   => '*',
        classes => '*',
      },
    ],
  }

  Mcollective::Module_plugin <| |> ~> Class['choria::service']
}
