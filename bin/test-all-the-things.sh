#!/bin/sh

set -e

test_infrastructure()
{
  echo "===> Testing $1 - Puppet $2"
  ./build-openvox-infrastructure.sh $1 $2
  ./destroy-puppet-infrastructure.sh
}

test_infrastructure f15 7
test_infrastructure f15 8
