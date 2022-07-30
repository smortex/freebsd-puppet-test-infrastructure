#!/bin/sh

if [ $# -ne 2 ]; then
  cat << EOT >&2
usage: $0 template
EOT
  exit 1
fi

TEMPLATE="$1"
puppet_version="$2"

JAIL=puppetboard.lan
iocage create -t $TEMPLATE -n $JAIL vnet=on ip4_addr='vnet0|10.0.0.12' defaultrouter=10.0.0.1
iocage start $JAIL
iocage exec $JAIL "pkg install -yU puppet${puppet_version}"
iocage exec $JAIL 'puppet module install /root/puppetlabs-host_core-1.0.3.tar.gz --force'
iocage exec $JAIL 'puppet apply' < manifests/common.pp
iocage exec $JAIL 'puppet agent -t || :'

