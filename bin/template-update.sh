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
  bastille template $TEMPLATE_NAME templates/base
fi

bastille stop $TEMPLATE_NAME
