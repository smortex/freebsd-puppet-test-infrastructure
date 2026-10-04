#!/bin/sh

postgresql_version=17

if [ $# -ne 2 ]; then
  cat << EOT >&2
usage: $0 freebsd-version openvox-version
EOT
  exit 1
fi

wait_for_openvoxserver()
{
  set +x
  printf "Waiting for OpenvoxServer to be ready"
  try=0
  while ! podman exec puppet nc -z 10.0.0.10 8140; do
    try=$((try + 1))
    if [ $try -eq 60 ]; then
      echo
      echo "Timeout reached while waiting for OpenvoxServer to be ready" >&2
      exit 1
    fi
    printf "."
    sleep 1
  done
  echo
  set -x
}

freebsd_image="localhost/freebsd-puppet-test-infra:$1"
puppet_version="$2"

set -ex

podman network create --subnet 10.0.0.0/24 puppet

JAIL=puppet
podman run --detach --name $JAIL --hostname $JAIL.lan --network puppet --ip 10.0.0.10 $freebsd_image
podman exec $JAIL pkg install -y openvox-agent${puppet_version} openvox-server${puppet_version} openvoxdb-terminus${puppet_version}
podman exec $JAIL puppet config set --section main server puppet.lan
podman exec $JAIL puppet config set --section main dns_alt_names puppet,puppet.lan
podman exec -i $JAIL puppet apply < manifests/common.pp
podman exec -i $JAIL puppet apply < manifests/puppetserver.pp
podman exec $JAIL service puppetserver restart

JAIL=puppetdb
podman run --detach --name $JAIL --hostname $JAIL.lan --network puppet --ip 10.0.0.11 --annotation 'org.freebsd.jail.allow.sysvipc=true' $freebsd_image
podman exec $JAIL pkg install -y openvox-agent${puppet_version} openvoxdb${puppet_version} postgresql${postgresql_version}-server postgresql${postgresql_version}-contrib postgresql${postgresql_version}-client sudo icu
podman exec $JAIL puppet config set --section main server puppet.lan
podman exec -i $JAIL puppet apply < manifests/common.pp
podman exec $JAIL puppet resource service postgresql enable=true
podman exec $JAIL service postgresql initdb
podman exec $JAIL service postgresql start
podman exec $JAIL sh -c "echo \"CREATE ROLE puppetdb LOGIN ENCRYPTED PASSWORD 'puppetdb'\" | sudo -u postgres psql"
podman exec $JAIL sh -c "echo \"CREATE DATABASE puppetdb OWNER puppetdb\" | sudo -u postgres psql"
podman exec $JAIL sh -c "echo \"CREATE EXTENSION pg_trgm;\" | sudo -u postgres psql puppetdb"
podman exec $JAIL sh -c "echo \"host    all             all             10.0.0.11/32        md5\" >> /var/db/postgres/data${postgresql_version}/pg_hba.conf"
podman exec $JAIL sh -c "sed -i '' -e \"s/#listen_addresses = '[^']*'/listen_addresses = '*'/\" /var/db/postgres/data${postgresql_version}/postgresql.conf"
podman exec $JAIL sh -c 'service postgresql restart'

podman exec $JAIL sh -c 'echo "subname = //10.0.0.11:5432/puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
podman exec $JAIL sh -c 'echo "username = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
podman exec $JAIL sh -c 'echo "password = puppetdb" >> /usr/local/etc/puppetdb/conf.d/database.ini'
wait_for_openvoxserver
podman exec $JAIL sh -c 'puppet agent -t || :'
if [ $puppet_version -eq 5 ]; then
  podman exec puppet puppet cert sign --all
else
  podman exec puppet puppetserver ca sign --all
fi
podman exec $JAIL sh -c 'puppet agent -t || :'
podman exec $JAIL puppetdb ssl-setup
podman exec $JAIL puppet resource service puppetdb enable=true
podman exec $JAIL service puppetdb start

podman exec -i puppet tee /usr/local/etc/puppet/puppetdb.conf << EOT
[main]
server_urls = https://puppetdb.lan:8081
EOT
podman exec puppet puppet config set --section main storeconfigs true
podman exec puppet puppet config set --section main storeconfigs_backend puppetdb
podman exec puppet puppet config set --section main reports puppetdb
podman exec -i puppet tee /usr/local/etc/puppet/routes.yaml << EOT
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOT
podman exec puppet service puppetserver restart
wait_for_openvoxserver

JAIL=puppetboard
podman run --detach --name $JAIL --hostname $JAIL.lan --network puppet --ip 10.0.0.12 $freebsd_image
podman exec $JAIL pkg install -y openvox-agent${puppet_version}
podman exec $JAIL puppet config set --section main server puppet.lan
podman exec -i $JAIL puppet apply < manifests/common.pp
podman exec $JAIL sh -c 'puppet agent -t || :'

JAIL=node1
podman run --detach --name $JAIL --hostname $JAIL.lan --network puppet --ip 10.0.0.100 $freebsd_image
podman exec $JAIL pkg install -y openvox-agent${puppet_version}
podman exec $JAIL puppet config set --section main server puppet.lan
podman exec -i $JAIL puppet apply < manifests/common.pp
podman exec $JAIL sh -c 'puppet agent -t || :'

JAIL=node2
podman run --detach --name $JAIL --hostname $JAIL.lan --network puppet --ip 10.0.0.101 $freebsd_image
podman exec $JAIL pkg install -y openvox-agent${puppet_version}
podman exec $JAIL puppet config set --section main server puppet.lan
podman exec -i $JAIL puppet apply < manifests/common.pp
podman exec $JAIL sh -c 'puppet agent -t || :'

podman exec 'puppet' puppetserver ca sign --all

podman exec -i 'puppet' sh -c 'puppet apply --detailed-exitcodes; if [ $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi' < manifests/r10k.pp

for node in puppet puppetdb puppetboard node1 node2; do
	podman exec $node sh -c 'puppet agent --test --detailed-exitcodes; if [ $? -ne 0 -a $? -ne 2 ]; then echo "Failed to apply catalog"; exit 1; fi'
	podman exec -i $node puppet apply < manifests/puppet.pp
done
