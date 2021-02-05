# Choria server configuration
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
    client => $client,
  }

  Mcollective::Module_plugin <| |> ~> Class['choria::service']
}
