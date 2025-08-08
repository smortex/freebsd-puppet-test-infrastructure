#!/bin/sh

bastille destroy --auto --yes puppet
bastille destroy --auto --yes puppetdb
bastille destroy --auto --yes puppetboard
bastille destroy --auto --yes node1
bastille destroy --auto --yes node2
