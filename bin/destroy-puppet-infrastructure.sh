#!/bin/sh

bastille destroy --auto --yes --force puppet
bastille destroy --auto --yes --force puppetdb
bastille destroy --auto --yes --force puppetboard
bastille destroy --auto --yes --force node1
bastille destroy --auto --yes --force node2
