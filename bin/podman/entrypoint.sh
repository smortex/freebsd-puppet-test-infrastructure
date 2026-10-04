#!/bin/sh
trap '/bin/sh /etc/rc.shutdown && exit 0' TERM INT

/bin/sh /etc/rc

while :; do
	sleep 3600 &
	wait
done
