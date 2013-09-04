#!/bin/bash
# filename: gearmand job server
#

pidfile=/var/run/gearman/gearmand.pid
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

case $1 in
    'start')
	echo "starting gearmand..."
	/usr/sbin/gearmand -d -L 127.0.0.1 -p 4730 -u processing -P $pidfile -q libsqlite3 --libsqlite3-db=$DIR/gearman.db -l /data/logs/gearmand.log
	;;
    'stop')
	/usr/bin/pkill -F $pidfile
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f $pidfile
	;;
    *)
	echo "usage: gearmand.sh {start|stop}"
	;;
esac
exit 0
