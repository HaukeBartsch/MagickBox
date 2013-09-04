#!/bin/sh
# gearman worker

pidfile=/var/run/gearman-worker-bucket01.pid

case $1 in
    'start')
	echo "starting gearman for bucket01..."
	/usr/bin/gearman -h 127.0.0.1 -p 4730 -w -f "bucket01" -- xargs -0 /data/streams/bucket01/work.sh &
	pid=$!
	echo $pid > $pidfile
	;;
    'stop')
	/usr/bin/pkill -F $pidfile
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f $pidfile
	;;
    *)
	echo "usage: gearman-worker-bucket01.sh { start | stop }"
	;;
esac
exit 0
