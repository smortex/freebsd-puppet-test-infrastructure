#!/bin/sh

usage()
{
  echo "usage: $0 -r RELEASE TEMPLATE_NAME" >&2
  exit 1
}

args=`getopt p:r: $*`
if [ $? -ne 0 ]; then
  usage
fi

set -- $args

while :; do
  case "$1" in
    -r)
      RELEASE="$2"
      shift
      shift
      ;;
    --)
      shift
      break
      ;;
  esac
done

if [ -z "$RELEASE" -o $# -ne 1 ]; then
  usage
fi

TEMPLATE_NAME="$1"

set -ex

iocage create -r $RELEASE -n $TEMPLATE_NAME vnet=on ip4_addr="vnet0|10.0.0.2/24" defaultrouter="10.0.0.1"

iocage start $TEMPLATE_NAME
iocage exec $TEMPLATE_NAME "env ASSUME_ALWAYS_YES=yes pkg bootstrap"
iocage exec $TEMPLATE_NAME "pkg install -y ca_root_nss"
iocage exec $TEMPLATE_NAME "mkdir -p /usr/local/etc/pkg/repos/"
iocage exec $TEMPLATE_NAME "cat > /usr/local/etc/pkg/repos/FreeBSD.conf" << EOT
FreeBSD: {
  url:            "http://10.0.0.1:8080/packages/$(echo $RELEASE | sed -e 's/[.-]/_/g' )_amd64-default",
  mirror_type:    "http",
  enabled:        yes,
  priority:       10,
  signature_type: "none",
}
EOT
iocage exec $TEMPLATE_NAME "pkg update"
iocage exec $TEMPLATE_NAME "pkg upgrade -y"
iocage exec $TEMPLATE_NAME "pkg fetch -yd puppet6 puppet7 puppetserver6 puppetserver7 puppetdb6 puppetdb7 puppetdb-terminus6 puppetdb-terminus7 postgresql11-server postgresql11-contrib git-lite"
iocage exec $TEMPLATE_NAME "fetch -o /root https://forge.puppet.com/v3/files/puppetlabs-host_core-1.0.3.tar.gz"

iocage stop $TEMPLATE_NAME
iocage set template=yes $TEMPLATE_NAME
