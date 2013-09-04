#!/bin/sh
# gearman worker

pidfile=/var/run/gearman-worker-bucket02.pid

case $1 in
    'start')
	echo "starting gearman for bucket02..."
	/usr/bin/gearman -h 127.0.0.1 -p 4730 -w -f "bucket02" -- xargs -0 /data/streams/bucket02/work.sh &
	pid=$!
	echo $pid > $pidfile
	;;
    'stop')
	/usr/bin/pkill -F $pidfile
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f $pidfile
	;;
    *)
	echo "usage: gearman-worker-bucket02.sh { start | stop }"
	;;
esac
exit 0
