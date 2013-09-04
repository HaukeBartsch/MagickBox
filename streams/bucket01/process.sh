#!/bin/bash

#
# This script is called if DICOM data is send to the system (end of study).
#
if [ $# -eq 0 ]
then
   echo "usage: process.sh <aetitle caller> <aetitle called> <caller IP> <dicom directory>"
   exit 1
fi

# get the PARENTIP and PARENTPORT variables
. /data/code/setup.sh
#echo "we can read these from setup.sh: $PARENTIP $PARENTPORT" >> /data/logs/bucket01.log

AETitleCaller=$1
AETitleCalled=$2
CallerIP=$3
DIR=$4
WORKINGDIR=`mktemp -d --tmpdir=/data/scratch/`
chmod gou+rwx $WORKINGDIR
mkdir ${WORKINGDIR}/INPUT

echo "`date`: Process bucket01 received data for processing in $WORKINGDIR (moving)" >> /data/logs/bucket01.log

# move the data away first
mv $DIR ${WORKINGDIR}/INPUT/

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

echo "`date`: Process bucket01 (send to DCM4CHEE)" >> /data/logs/bucket01.log

# DCM4CHEE for save keeping
# /usr/bin/storescu -aet "Processing" -aec "DCM4CHEE" +r +sd XXX.XXX.XXX.XXX 11111 $WORKINGDIR
/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -b -- "${WORKINGDIR}/INPUT"

echo "`date`: Process bucket01 (processing...)" >> /data/logs/bucket01.log

if [ $AETitleCalled = \"ProcRSITBI\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket04RSITBI -- "${WORKINGDIR}/INPUT"
elif [ $AETitleCalled = \"ProcRSIProstate\" ]
then 
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket05RSIProstate -- "${WORKINGDIR}/INPUT"
elif [ $AETitleCalled = \"ProcRSIMS\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket06RSIMS -- "${WORKINGDIR}/INPUT"
elif [ $AETitleCalled = \"RSIProsUCSD\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket07RSIProstateP2 -- "${WORKINGDIR}/INPUT"
else 
  echo "`date`: Error: unknown job type ($CallerIP requested $AETitleCalled), ignored" >> /data/logs/bucket01.log
fi

# try to send back to osirix on parent machine
echo "`date`: Process bucket01 (send results to DCM4CHEE on \"$PARENTIP\" \"$PARENTPORT\"...)" >> /data/logs/bucket01.log
/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -- "${WORKINGDIR}/OUTPUT $PARENTIP $PARENTPORT"
echo "`date`: Process bucket01 (send results done...)" >> /data/logs/bucket01.log
