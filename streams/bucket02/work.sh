#!/bin/bash
#
# This script is called by other scripts using the gearman02 worker.
# This guarantees that a single instance sends data to the PACS.
#

# here we can execute something with the data in the input
if [ $# -eq 0 ]
then
  echo "usage: work.sh <DICOM directory>"
  echo "usage: work.sh <DICOM directory>" >> /data/logs/bucket02.log
  exit 1
fi

# get the PARENTIP and PARENTPORT variables
. /data/code/setup.sh

INP=$1
INP=( $INP )
DATA=${INP[0]}
SERVER=${PARENTIP}
# default port
PORT=11111

echo "`date`: start processing \"${INP[*]}\"" >> /data/logs/bucket02.log
logger "start processing \"${INP[*]}\""

if [ ${#INP[@]} -eq 3 ]
then
  SERVER=${INP[1]}
  PORT=${INP[2]}
  echo "`date`: only SERVER and PORT are provided in \"${INP[*]}\"" >> /data/logs/bucket02.log
  logger "Error: only SERVER and PORT are available"
fi

AETitleSender="Processing"
AETitleTo="UNKNOWN"

if [ ${#INP[@]} -eq 5 ]
then
  SERVER=${INP[1]}
  PORT=${INP[2]}
  AETitleSender=${INP[3]}
  AETitleTo=${INP[4]}
else
  echo "`date`: use default values for AETitleTo and AETitleSender, they are not in \"${INP[*]}\"" >> /data/logs/bucket02.log
  logger "warning: use default values for AETitleTo and AETitleSender"
fi

echo "`date`: send files to \"$SERVER\" \"$PORT\" \"$AETitleTo\" \"$AETitleSender\" ($DATA) start..." >> /data/logs/bucket02.log

# check if we have DICOM files, copy them somewhere for transfer
TEMP=`mktemp -d`
chmod 777 "${TEMP}"
c=0
find -L ${DATA} -type f -print0 |
while read -r -d '' u
do
  /usr/bin/dcmftest "$u" > /dev/null
  if [ $? -ne 0 ]; then
     echo "`date`: found ${u}, is not DICOM, skip" >> /data/logs/bucket02.log
     continue
  fi

  fn=${TEMP}/dicom_$(printf '%04d' $c).dcm
  # echo "create file $u as $fn" >> /data/logs/bucket02.log
  ln -s "$u" "$fn"
  c=$(( c + 1 ))
done
echo "`date`: send DICOM files from ${TEMP}" >> /data/logs/bucket02.log

/usr/bin/storescu -aet $AETitleSender -aec $AETitleTo -nh -xy +r +sd $SERVER $PORT $TEMP >> /data/logs/bucket02.log 2>&1
if [ $? -ne 0 ]
then
  echo "`date`: error on send \"$DATA\" to \"${AETitleTo}\"" >> /data/logs/bucket02.log
  logger "Error: could not send \"$DATA\" to \"${AETitleTo}\""
  # keep a log of stuff that fails
  mkdir -p /data/scratch/sendfailed/
  errorFile=`echo ${DATA} | sed -e 's/\//_/g'`
  echo "/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -- $@" > /data/scratch/sendfailed/$errorFile
  echo "Keep track of failed: /data/scratch/sendfailed/$errorFile" >> /data/logs/bucket02.log
  logger "Keep track of failed: /data/scratch/sendfailed/$errorFile"
else
  echo "`date`: send files to \"${AETitleTo}\" ($DATA) done" >> /data/logs/bucket02.log
  logger "send files to \"${AETitleTo}\" ($DATA) done"
fi

# remove the data directory again
echo "`date`: delete temporary files to in ${TEMP}..." >> /data/logs/bucket02.log
/bin/rm -R -f ${TEMP}
