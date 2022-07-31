host { 'puppet.lan':
  ip           => '10.0.0.10',
  host_aliases => [
    'puppet',
  ],
}
host { 'puppetdb.lan':
  ip           => '10.0.0.11',
  host_aliases => [
    'puppetdb',
  ],
}
host { 'puppetboard.lan':
  ip           => '10.0.0.12',
  host_aliases => [
    'puppetboard',
  ],
}
host { 'node1.lan':
  ip           => '10.0.0.100',
  host_aliases => [
    'node1',
  ],
}
host { 'node2.lan':
  ip           => '10.0.0.101',
  host_aliases => [
    'node2',
  ],
}
