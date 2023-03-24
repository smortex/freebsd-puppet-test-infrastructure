#!/bin/sh

if [ $# -ne 2 ]; then
  cat << EOT >&2
usage: $0 template puppet-version
EOT
  exit 1
fi

wait_for_puppetserver()
{
  set +x
  printf "Waiting for PuppetServer to be ready"
  try=0
  while ! nc -z 10.0.0.10 8140; do
    try=$((try + 1))
    if [ $try -eq 60 ]; then
      echo
      echo "Timeout reached while waiting for PuppetServer to be ready" >&2
      exit 1
    fi
    printf "."
    sleep 1
  done
  echo
  set -x
}

TEMPLATE="$1"
puppet_version="$2"

set -ex

JAIL=puppet
bastille clone $TEMPLATE $JAIL 10.0.0.10
bastille start $JAIL
bastille pkg $JAIL install -y puppet${puppet_version} puppetserver${puppet_version} puppetdb-terminus${puppet_version}
bastille cmd $JAIL puppet apply < manifests/common.pp
bastille cmd $JAIL puppet apply < manifests/puppetserver.pp
bastille cmd $JAIL service puppetserver restart

JAIL=puppetdb
bastille clone $TEMPLATE $JAIL 10.0.0.11
sudo bastille config puppetdb set allow.raw_sockets 1
sudo bastille config puppetdb set allow.sysvipc 1
bastille start $JAIL
bastille pkg $JAIL install -y puppet${puppet_version} puppetdb${puppet_version} postgresql11-server postgresql11-client sudo icu
bastille cmd $JAIL puppet apply < manifests/common.pp
bastille sysrc $JAIL postgresql_enable=yes
bastille cmd $JAIL service postgresql initdb
bastille cmd $JAIL service postgresql start
bastille cmd $JAIL sh -c "echo \"CREATE ROLE puppetdb LOGIN ENCRYPTED PASSWORD 'puppetdb'\" | sudo -u postgres psql"
bastille cmd $JAIL sh -c "echo \"CREATE DATABASE puppetdb OWNER puppetdb\" | sudo -u postgres psql"
bastille cmd $JAIL sh -c "echo \"CREATE EXTENSION pg_trgm;\" | sudo -u postgres psql puppetdb"
bastille cmd $JAIL sh -c "echo \"host    all             all             10.0.0.11/32        md5\" >> /var/db/postgres/data11/pg_hba.conf"
bastille cmd $JAIL sh -c "sed -i '' -e \"s/#listen_addresses = '[^']*'/listen_addresses = '*'/\" /var/db/postgres/data11/postgresql.conf"
bastille cmd $JAIL sh -c 'service postgresql restart'

bastille cmd $JAIL sh -c 'echo "subname = //10.0.0.11:5432/puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
bastille cmd $JAIL sh -c 'echo "username = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
bastille cmd $JAIL sh -c 'echo "password = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
wait_for_puppetserver
bastille cmd $JAIL sh -c 'puppet agent -t || :'
if [ $puppet_version -eq 5 ]; then
  bastille cmd puppet puppet cert sign --all
else
  bastille cmd puppet puppetserver ca sign --all
fi
bastille cmd $JAIL sh -c 'puppet agent -t || :'
bastille cmd $JAIL puppetdb ssl-setup
bastille sysrc $JAIL puppetdb_enable=yes
bastille cmd $JAIL service puppetdb start

bastille cmd puppet tee /usr/local/etc/puppet/puppetdb.conf << EOT
[main]
server_urls = https://puppetdb.lan:8081
EOT
bastille cmd puppet tee /usr/local/etc/puppet/puppet.conf << EOT
[master]
  storeconfigs = true
  storeconfigs_backend = puppetdb
  reports = puppetdb
EOT
bastille cmd puppet tee /usr/local/etc/puppet/routes.yaml << EOT
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOT
bastille cmd puppet service puppetserver restart
wait_for_puppetserver

JAIL=puppetboard
bastille clone $TEMPLATE $JAIL 10.0.0.12
bastille start $JAIL
bastille pkg $JAIL install -y puppet${puppet_version}
bastille cmd $JAIL puppet apply < manifests/common.pp
bastille cmd $JAIL sh -c 'puppet agent -t || :'

JAIL=node1
bastille clone $TEMPLATE $JAIL 10.0.0.100
bastille start $JAIL
bastille pkg $JAIL install -y puppet${puppet_version}
bastille cmd $JAIL puppet apply < manifests/common.pp
bastille cmd $JAIL sh -c 'puppet agent -t || :'

JAIL=node2
bastille clone  $TEMPLATE $JAIL 10.0.0.101
bastille start $JAIL
bastille pkg $JAIL install -y puppet${puppet_version}
bastille cmd $JAIL puppet apply < manifests/common.pp
bastille cmd $JAIL sh -c 'puppet agent -t || :'

bastille cmd 'puppet' puppetserver ca sign --all

bastille cmd 'puppet' sh -c 'puppet apply --detailed-exitcodes; if [ $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi' < manifests/r10k.pp

for node in puppet puppetdb puppetboard node1 node2; do
	bastille cmd $node sh -c 'puppet agent --test --detailed-exitcodes; if [ $? -ne 0 -a $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi'
	bastille cmd $node puppet apply < manifests/puppet.pp
done
