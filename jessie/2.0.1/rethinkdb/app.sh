#!/bin/bash

if [ -z "$MASTER" ]
then
	echo "PLEASE SET 'MASTER' variable"
	exit 1
fi

echo "Joining to consul master: $MASTER"
/bin/launch.sh &

consul join $MASTER

joiner=`dig @$MASTER rethinkdb-intracluster.service.consul +short`

echo "found host: $joiner"
currentIp=`ip route get 8.8.8.8 | awk 'NR==1 {print $NF}'`
echo "Have current ip: $currentIp"

if [ -z "$joiner" ]
then
	echo "Starting a cluster!"
	rethinkdb --bind all "$@"
else
	echo "Joining a cluster!!!"
	rethinkdb --bind all --join "$joiner" "$@"
fi