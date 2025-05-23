#!/bin/sh

bastille destroy --auto puppet
bastille destroy --auto puppetdb
bastille destroy --auto puppetboard
bastille destroy --auto node1
bastille destroy --auto node2
