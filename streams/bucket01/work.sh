#!/bin/bash

# here we can execute something with the data in the input
if [ $# -eq 0 ]
then
   echo "usage: work.sh <DICOM directory>"
   exit 1
fi

DATA=$1

echo "`date`: do some gearman work.sh on \"$DATA\"" >> /data/logs/bucket01.log
