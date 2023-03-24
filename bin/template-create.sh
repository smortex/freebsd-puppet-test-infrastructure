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

bastille create $TEMPLATE_NAME $RELEASE 10.0.0.2
bastille template $TEMPLATE_NAME templates/base
bastille stop $TEMPLATE_NAME
