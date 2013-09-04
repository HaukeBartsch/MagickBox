#!/bin/bash
#
# This script is calles my code.
# Processing for data
#

# here we can execute something with the data in the input
if [ $# -eq 0 ]
then
   echo "usage: work.sh <DICOM directory>"
   echo "usage: work.sh <DICOM directory>" >> /data/logs/mypackage.log
   exit 1
fi

DATA=$1
OUTPUT=${DATA}/../OUTPUT

echo "`date`: processing Prostate data ($DATA) start..." >> /data/logs/bucket05.log

mkdir -p ${OUTPUT}
sh /data/streams/mypackage/run_my_stuff.sh $DATA $OUTPUT > ${DATA}/../processing.log
echo "`date`: processing ($DATA) done" >> /data/logs/mypackage.log

echo "`date`: processing ($OUTPUT) send to DCM4CHEE" >> /data/logs/mypackage.log

# send data back to our PACS
/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -b -- "${OUTPUT}"

echo "`date`: processing mypackage ($DATA) send to DCM4CHEE done" >> /data/logs/mypackage.log
