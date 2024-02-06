#!/bin/sh

set -e

test_infrastructure()
{
  echo "===> Testing $1 - Puppet $2"
  ./build-puppet-infrastructure.sh $1 $2
  ./destroy-puppet-infrastructure.sh
}

#test_infrastructure f12 6
#test_infrastructure f12 7
test_infrastructure f13 7
test_infrastructure f13 8
test_infrastructure f14rc4 7
test_infrastructure f14rc4 8
