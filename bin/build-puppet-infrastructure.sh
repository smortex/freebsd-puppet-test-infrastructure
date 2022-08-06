#!/bin/sh

if [ $# -ne 2 ]; then
  cat << EOT >&2
usage: $0 template puppet-version
EOT
  exit 1
fi

TEMPLATE="$1"
puppet_version="$2"

set -ex

JAIL=puppet.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.10' defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version} puppetserver${puppet_version} puppetdb-terminus${puppet_version}"
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'puppet apply' < manifests/puppetserver.pp
iocage exec $JAIL 'service puppetserver restart'

JAIL=puppetdb.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.11' allow_sysvipc=1 defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version} puppetdb${puppet_version} postgresql11-server postgresql11-client sudo icu"
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'sysrc postgresql_enable=yes'
iocage exec $JAIL 'service postgresql initdb'
iocage exec $JAIL 'service postgresql start'
iocage exec $JAIL "echo \"CREATE ROLE puppetdb LOGIN ENCRYPTED PASSWORD 'puppetdb'\" | sudo -u postgres psql"
iocage exec $JAIL "echo \"CREATE DATABASE puppetdb OWNER puppetdb\" | sudo -u postgres psql"
iocage exec $JAIL "echo \"CREATE EXTENSION pg_trgm;\" | sudo -u postgres psql puppetdb"
iocage exec $JAIL "echo \"host    all             all             10.0.0.11/32        md5\" >> /var/db/postgres/data11/pg_hba.conf"
iocage exec $JAIL "sed -i '' -e \"s/#listen_addresses = '[^']*'/listen_addresses = '*'/\" /var/db/postgres/data11/postgresql.conf"
iocage exec $JAIL 'service postgresql restart'

iocage exec $JAIL 'echo "subname = //10.0.0.11:5432/puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
iocage exec $JAIL 'echo "username = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
iocage exec $JAIL 'echo "password = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
echo '===> Waiting to Puppet Server to start...'
sleep 10
iocage exec $JAIL 'puppet agent -t || :'
if [ $puppet_version -eq 5 ]; then
  iocage exec puppet.lan 'puppet cert sign --all'
else
  iocage exec puppet.lan 'puppetserver ca sign --all'
fi
iocage exec $JAIL 'puppet agent -t || :'
iocage exec $JAIL 'puppetdb ssl-setup'
iocage exec $JAIL 'sysrc puppetdb_enable=yes'
iocage exec $JAIL 'service puppetdb start'

iocage exec puppet.lan 'tee /usr/local/etc/puppet/puppetdb.conf' << EOT
[main]
server_urls = https://puppetdb.lan:8081
EOT
iocage exec puppet.lan 'tee /usr/local/etc/puppet/puppet.conf' << EOT
[master]
  storeconfigs = true
  storeconfigs_backend = puppetdb
  reports = puppetdb
EOT
iocage exec puppet.lan 'tee /usr/local/etc/puppet/routes.yaml' << EOT
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOT
iocage exec puppet.lan 'service puppetserver restart'

JAIL=puppetboard.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.12' defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version}"
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'puppet agent -t || :'

JAIL=node1.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.100' defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version}"
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'puppet agent -t || :'

JAIL=node2.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.101' defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version}"
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'puppet agent -t || :'

iocage exec 'puppet.lan' 'puppetserver ca sign --all'

iocage exec 'puppet.lan' 'puppet apply --detailed-exitcodes; if [ $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi' < manifests/r10k.pp

for node in puppet.lan puppetdb.lan puppetboard.lan node1.lan node2.lan; do
	iocage exec $node 'puppet agent --test --detailed-exitcodes; if [ $? -ne 0 -a $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi'
done

iocage exec $JAIL 'puppet apply' < manifests/puppet.pp
