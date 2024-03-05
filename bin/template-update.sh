#!/bin/sh

usage()
{
  echo "usage: $0 [-i] TEMPLATE_NAME" >&2
  exit 1
}

args=`getopt i $*`
if [ $? -ne 0 ]; then
  usage
fi

interactive=0

set -- $args

while :; do
  case "$1" in
    -i)
      interactive=1
      shift
      ;;
    --)
      shift
      break
      ;;
  esac
done

if [ $# -ne 1 ]; then
  usage
fi

TEMPLATE_NAME=$1

set -ex

bastille start $TEMPLATE_NAME

if [ $interactive -eq 1 ]; then
  bastille console $TEMPLATE_NAME
else
  bastille cmd $TEMPLATE_NAME pkg update
  bastille cmd $TEMPLATE_NAME pkg upgrade -y
  bastille cmd $TEMPLATE_NAME pkg fetch -yd puppet7 puppet8 puppetserver7 puppetserver8 puppetdb7 puppetdb8 puppetdb-terminus7 puppetdb-terminus8 postgresql15-server postgresql15-contrib py39-puppetboard git-lite rubygem-r10k choria rubygem-choria-mcorpc-support rubygem-net-ping uwsgi-py39
fi

bastille stop $TEMPLATE_NAME
