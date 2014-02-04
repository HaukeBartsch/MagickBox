#!/bin/bash

if [ $# -ne 3 ]; then
   echo "usage: $0 <processing.log> <INPUTdcmDir> <OUTPUTdcmDir>"
   exit
fi

PROC=$1
INPUT=$2
OUTPUT=$3

tmpfile=${PROC##*/}
fnamejpeg=$OUTPUT/${tmpfile%.*}.jpeg
fnamedcm=$OUTPUT/${tmpfile%.*}.dcm
inDcmFiles=($(find $INPUT -type f))
#echo $inDcmFiles

tail $PROC | grep -v "dir_simple" | strings | fold | convert text:- $fnamejpeg
/usr/bin/img2dcm $fnamejpeg $fnamedcm -sc -stf $inDcmFiles
/usr/bin/dcmodify -ie -i "SeriesDescription=Error Report" $fnamedcm
rm $fnamedcm.bak $fnamejpeg
