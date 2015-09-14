#!/bin/bash

#
# check the study job directory created by receiveSingleFile.sh
# if the file is old enough process it using the information provided
# Add this to 'crontab -e' to check every 15 seconds if a new job arrived. 
# */1 * * * * /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 30; /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 15; /data/code/bin/detectStudyArrival.sh
# */1 * * * * sleep 45; /data/code/bin/detectStudyArrival.sh


DIR=/data/scratch/.arrived
if [ ! -d "$DIR" ]; then
  mkdir -p "$DIR"
  chmod 777 "$DIR"
fi


# only done if at least that old (in seconds)
oldtime=15

detect () {
  # every file in this directory is a potential job, but we need to find some that are old enough
  find "$DIR" -print0 | while read -d $'\0' file
  do
    if [ "$file" == "$DIR" ]; then
       continue
    fi
    if [ "$(( $(date +"%s") - $(stat -c "%Y" "$file") ))" -lt "$oldtime" ]; then
        continue
    fi

    echo "`date`: Detected an old enough job \"$file\"" >> /data/logs/detectStudyArrival.log
    fileName=$(basename "$file")
    AETitleCaller=`echo "$fileName" | cut -d' ' -f1`
    AETitleCalled=`echo "$fileName" | cut -d' ' -f2`
    CallerIP=`echo "$fileName" | cut -d' ' -f3`
    SDIR=`echo "$fileName" | cut -d' ' -f4`
    echo "`date`: run the following job : \"$AETitleCaller\" \"$AETitleCalled\" $CallerIP /data/scratch/archive/$SDIR" >> /data/logs/detectStudyArrival.log
    /usr/bin/nohup /data/streams/bucket01/process.sh \"$AETitleCaller\" \"$AETitleCalled\" $CallerIP "/data/scratch/archive/$SDIR" &
    echo "try to delete \"$file\" now" >> /data/logs/detectStudyArrival.log    
    /bin/rm -- "$file"
  done
}

# The following section takes care of not starting this script more than once 
# in a row. If for example it takes too long to run a single iteration this 
# will ensure that no second call to scrub is executed prematurely.
(
  flock -n 9 || exit 1
  # command executed under lock
  detect
) 9>/data/.pids/detectStudyArrival.lock
