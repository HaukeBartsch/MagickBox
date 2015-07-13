#!/bin/bash
# filename: storescpd
#
# purpose: start storescp server at boot time
# This script is started by monit (/etc/monit/conf.d/processing.conf).
#

tos=15
od=/data/scratch/archive
# create the output directory
mkdir -p ${od}
chmod -R 777 ${od}

port=1234
pidfile=/data/.pids/storescpd.pid
# the following script will get the aetitle of the caller, the called aetitle and the path to the data as arguments
#scriptfile=/data/streams/bucket01/process.sh
scriptfile=/data/code/bin/receiveSingleFile.sh

case $1 in
    'start')
	echo "Starting storescp daemon..."
	if [ ! -d "$od" ]; then
	    mkdir $od
	fi
	/usr/bin/storescp --fork \
	    --write-xfer-little \
	    --exec-on-reception "$scriptfile '#a' '#c' '#r' '#p' '#f' &" \
  	    --sort-on-study-uid scp \
	    --log-config /data/code/bin/logger.cfg \
	    --output-directory "$od" \
	    $port & &>/data/logs/storescpd.log
	pid=$!
	echo $pid > $pidfile
	;;
    'stop')
	/usr/bin/pkill -F $pidfile
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f $pidfile
	;;
    *)
	echo "usage: storescpd { start | stop }"
	;;
esac
exit 0
