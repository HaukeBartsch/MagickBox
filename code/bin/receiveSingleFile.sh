#!/bin/bash

#
# This script is called if DICOM data is send to the system (for every single file).
#
# Next step from here is that we need to detect if the last file for that study has
# arrived. If that is the case we can start process.sh in bucket01.
#
# Add a cron-job to make sure that we can test for a finished study.
# crontab -e
# */1 * * * * /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 15; /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 30; /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 45; /data/code/bin/detectStudyArrival.sh


if [ $# -eq 0 ]
then
   echo "usage: receiveSingleFile <aetitle caller> <aetitle called> <caller IP> <dicom directory> <DICOM file>"
   exit 1
fi

AETitleCaller=$1
AETitleCalled=$2
CallerIP=$3
DIR=$4
SDIR=$(basename "$DIR")
FILE=$5

#echo "got something" >> /data/logs/receivedSingleFile.log

WORKINGDIR=/data/scratch/.arrived
fn=`echo "${WORKINGDIR}/$AETitleCaller $AETitleCalled $CallerIP $SDIR" | sed -e 's/\"//g'`
echo "$DIR/$FILE" >> "${fn}"
#echo "$fn" >> /data/logs/receivedSingleFile.log
