#!/bin/bash
#
# create a heart beat for the storescp
# One way it can fail is if multiple associations are requested.
# If the timeout happens the connection will be unusable afterwards.
# Here we simply use echoscu to test the connection and if that
# fails we will kill a running storescp (hoping that monit will start it again).
#
# In order to activate put this into the crontab of processing (every minute)
#   */1 * * * * /usr/bin/nice -n 3 /data/code/bin/heartbeat.sh
#
#

# read in the configuration file
. /data/code/setup.sh

log=/data/logs/heartbeat.log

#echo "try now: /usr/bin/echoscu $PARENTIP $PARENTPORT"
timeout 10 /usr/bin/echoscu $PARENTIP $PARENTPORT
if (($? == 124)); then
   # get pid of storescu
   pid=`pgrep storesp`
   if [ "$pid" == "" ]; then
      echo "storescp could not be found" >> $log
      exit 0
   fi
   echo "`date`: detected unresponsive storescp, kill and hope that monit restarts it" >> $log
   # stop storescu gracefully first
   kill -s SIGTERM $pid && kill -0 $pid || exit 0
   sleep 5
   # more forceful
   kill -s SIGKILL $pid
fi
