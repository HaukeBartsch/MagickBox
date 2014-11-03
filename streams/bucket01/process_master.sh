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

# don't move the data away anymore, keep it in the archive and link to it only
eval /bin/ln -s ${DIR} ${WORKINGDIR}/INPUT
# create the output directory here
mkdir -p ${WORKINGDIR}/OUTPUT

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
# /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -b -- "${WORKINGDIR}/INPUT"

echo "`date`: Process bucket01 (processing...)" >> /data/logs/bucket01.log

# check the license
lic=`/usr/bin/curl http://mmil.ucsd.edu/MagickBox/queryLicense.php?feature=$AETitleCalled | cut -d':' -f2 | sed -e 's/[\"})]//g'`
if [ "$lic" == "-1" ]
then
  echo "`date`: Error: no permissions to run this job ($CallerIP requested $AETitleCalled), ignored" >> /data/logs/bucket01.log
fi
echo "`date`: can run this job $lic ($CallerIP requested $AETitleCalled)" >> /data/logs/bucket01.log

read s1 < <(date +'%s')
if [ $AETitleCalled = \"ProcRSITBI\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket04RSITBI -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
elif [ $AETitleCalled = \"ProcRSIProstate\" ]
then 
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket05RSIProstate -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
elif [ $AETitleCalled = \"ProcRSIMS\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket06RSIMS -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
elif [ $AETitleCalled = \"RSIProsUCSD\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket07RSIProstateP2 -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
elif [ $AETitleCalled = \"ProcTBIp01\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucketTBIp01 -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
elif [ $AETitleCalled = \"ProcRSIProstUCLA\" ]
then
  /usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket05RSIProstUCLA -- "${WORKINGDIR}/INPUT ${WORKINGDIR}/OUTPUT"
else 
  echo "`date`: Error: unknown job type ($CallerIP requested $AETitleCalled), ignored" >> /data/logs/bucket01.log
fi
read s2 < <(date +'%s')
/usr/bin/curl ${PARENTIP}:${WEBPORT}/code/php/timing.php?aetitle=${AETitleCalled}\&time=$(( s2 - s1 ))

# try to send back to osirix on parent machine
#echo "`date`: Process bucket01 (send results to DCM4CHEE on \"$PARENTIP\" \"$PARENTPORT\"...)" >> /data/logs/bucket01.log
#/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -- "${WORKINGDIR}/OUTPUT $PARENTIP $PARENTPORT"
#echo "`date`: Process bucket01 (send results done...)" >> /data/logs/bucket01.log

# implement routing
echo "`date`: Process bucket01 (starts routing)..." >> /data/logs/bucket01.log
/data/code/bin/routing.sh ${WORKINGDIR} $AETitleCalled $AETitleCaller
echo "`date`: Process bucket01 (routing is being performed)..." >> /data/logs/bucket01.log
