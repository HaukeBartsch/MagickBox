#!/bin/bash

#
# This script is called if DICOM data is send to the system (end of study).
#
if [ $# -eq 0 ]
then
   echo "usage: process.sh <aetitle caller> <aetitle called> <caller IP> <dicom directory>"
   exit 1
fi

# get the PARENTIP and PARENTPORT/WEBPORT variables
. /data/code/setup.sh
# echo "we can read these from setup.sh: $PARENTIP $PARENTPORT" >> /data/logs/bucket01.log

AETitleCaller=$1
AETitleCalled=$2
CallerIP=$3
DIR=$4
WORKINGDIR=`mktemp -d --tmpdir=/data/scratch/`
chmod gou+rwx $WORKINGDIR
mkdir ${WORKINGDIR}

echo "`date`: Process bucket01 received data for processing in $WORKINGDIR (moving)" >> /data/logs/bucket01.log

# don't move the data away anymore, keep it in the archive and link to it only (INPUT should not exist here!)
eval /bin/ln -s ${DIR} ${WORKINGDIR}/INPUT
# files need to be deletable by apache later
chmod -R gou+rwx ${WORKINGDIR}/INPUT

# store the sender information as text
(
cat <<EOF
{
   "CallerIP":"$CallerIP",
   "AETitleCalled":$AETitleCalled,
   "AETitleCaller":$AETitleCaller,
   "received":"`date`"
}
EOF
) > $WORKINGDIR/info.json

echo "`date`: Process bucket01 (processing...)" >> /data/logs/bucket01.log

# check the license
lic=`/usr/bin/curl "http://mmil.ucsd.edu/MagickBox/queryLicense.php?feature=$AETitleCalled&CallerIP=$CallerIP&AETitleCaller=$AETitleCaller" | cut -d':' -f2 | sed -e 's/[\"})]//g'`
if [ "$lic" == "-1" ]
then
  echo "`date`: Error: no permissions to run this job ($CallerIP requested $AETitleCalled), ignored" >> /data/logs/bucket01.log
fi
echo "`date`: can run this job $lic ($CallerIP requested $AETitleCalled)" >> /data/logs/bucket01.log

read s1 < <(date +'%s')
$found = 0
GEARMAN=`which gearman`
for stream in $( ls -d /data/streams/* ); do
  if [ -f $stream/info.json ]; then
      enabled=`cat $stream/info.json | jq ".enabled"`
      if [ "$enabled" == "1" ]; then
         AETitle=`cat $stream/info.json | jq ".AETitle"`
         AETitle1=`cat $stream/info.json | jq ".AETitle" | sed 's/\"//g'`
          if [ $AETitleCalled = $AETitle ]; then
           echo "start stream $AETitle..." >> /data/logs/bucket01.log
           $GEARMAN -h 127.0.0.1 -p 4730 -f bucket${AETitle1} -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
	   found=1
           break;
         fi
      fi
  fi
done
if [ "$found" -eq 0 ]; then
  echo "`date`: Error: unknown job type ($CallerIP requested $AETitleCalled), ignored" >> /data/logs/bucket01.log
fi
read s2 < <(date +'%s')
/usr/bin/curl ${PARENTIP}:${WEBPORT}/code/php/timing.php?aetitle=${AETitleCalled}\&time=$(( s2 - s1 ))

# implement routing
echo "`date`: Process bucket01 (starts routing)..." >> /data/logs/bucket01.log
/data/code/bin/routing.sh ${WORKINGDIR} $AETitleCalled $AETitleCaller
echo "`date`: Process bucket01 (routing is being performed)..." >> /data/logs/bucket01.log

# implement data extraction
echo "`date`: Start data extraction..." >> /data/logs/bucket01.log
aet=`echo $AETitleCaller | sed -e 's/"//g'`
aec=`echo $AETitleCalled | sed -e 's/"//g'`
/usr/bin/curl -G -d "sender=${aet}&bucket=${aec}&parse=${WORKINGDIR}/OUTPUT" ${PARENTIP}:${WEBPORT}/code/php/db.php
echo "`date`: End data extraction..." >> /data/logs/bucket01.log
