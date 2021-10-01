#!/bin/sh
iocage destroy -f puppet.lan
iocage destroy -f puppetdb.lan
iocage destroy -f node1.lan
iocage destroy -f node2.lan
