#!/bin/bash

# This script can be started by cron (something like every 30 minutes should work).
# It can be run several times, only the first run will actually work. Followup runs
# will fail until the first run is finished.
#
# Example crontab entry that starts this script every 30 minutes
#   */30 * * * * /usr/bin/nice -n 3 /data/code/bin/scrubStorage.sh
# Add the above line to your machine using:
#   > crontab -e
#

# read in the configuration file
. /data/code/setup.sh
# we look for SCRUBhighwatermark (percentages, 90)
# we look for SCRUBlowwatermark (percentages, 80)
# we look for SCRUBenable (0 - false, 1 - true)

# percentage value of hard drive filled when we have to do something
if [ -z ${SCRUBhighwaterborder+x} ]; then
  highwaterborder=90
else
  highwaterborder=$SCRUBhighwaterborder
fi
# we remove directories until we hit this border (should always be smaller)
if [ -z ${SCRUBlowwaterborder+x} ]; then
  lowwaterborder=80
else
  lowwaterborder=$SCRUBlowwaterborder
fi
# directory to scrub (look for tmp.* files only)
dir=/data/scratch
# location of log file
log=/data/logs/scrubStorage.log
# just checking or really removing stuff?
if [ -z ${SCRUBenable+x} ]; then
  enable=0
else
  enable=$SCRUBenable
fi

scrub () {
  echo "START SCRUBBING `date`" >> $log

  # before we scrub we should sweep, maybe there is no need to remove stuff afterwards
  sweep

  # find out how much space we have left in /data/scratch
  fr=`nice -n 3 df "$dir" | grep -v Filesystem | awk '{print $5}' | cut -d'%' -f1`
  if [ "$fr" -lt "$highwaterborder" ]; then
    echo "Nothing to do, border was not hit ($fr of $highwaterborder)" >> $log
    echo "END SCRUBBING `date`" >> $log
    return
  fi
  echo "(OK, we need to do something now)"

  available=`df $dir | grep -v Filesystem | awk '{print $4}'`
  used=`df $dir | grep -v Filesystem | awk '{print $3}'`
  perc=`bc -l <<< "100 - $available / ($available + $used) * 100"`
  target=`bc -l <<< "($available + $used)*(1.0-($lowwaterborder/100))-$available"`
  target=`printf "%.0f" $target`
  echo "INFO: need to reach $target bytes before we are happy again" >> $log
  printf "%.2f%%\n" $perc
  ret=`scrubList`
  accumulated=0
  for r in $ret; do
    # check if we can quit now
    if [ "$accumulated" -gt "$target" ]; then
       echo "`date` INFO: Target reached" >> $log
       echo "target reached"
       return
    fi

    f=`echo $r | cut -d';' -f2`
    s=`echo $r | cut -d';' -f1`
    accumulated=$(($accumulated + $s))
    echo "removing $f (cleans up $s bytes of space)"
    if [ "$enable" == "1" ]; then
       # we need to remove the input as well, its just a symbolic link in tmp.*
       input=`readlink -f $f/INPUT`
       if [ `echo $input | cut -d'/' -f1-3` != '/data/scratch' ]; then
          echo "ERROR: \"$input\" would need to be removed but is not in /data/scratch" >> $log
       else
          echo "`date` deleted \"$input\" which is inside \"$f\"" >> $log
          nice -n 3 /bin/rm -f -R "$input"
       fi
       # now remove the directory itself
       nice -n 3 /bin/rm -f -R "$f"
       echo "`date` deleted $f (cleans up $s bytes of space)" >> $log
    else
       echo "`date` could delete $f (would clean up $s bytes of space)" >> $log
    fi
    perc2=`bc -l <<< "100 - ($available + $accumulated) / (($available + $accumulated) + ($used - $accumulated)) * 100"`  
    printf "%.2f%% " $perc2
    ((i++))
  done 
  echo "STOP SCRUBBING `date`" >> $log
}

# this can take a long time, we should cache the size of files, maybe do something only we there
# are free cycles
scrubList () {
  # we can remove folders that are empty
  # we can remove folders that are inside /data/scratch
  # we don't want to delete anything in non- tmp.* folders
  unset a
  i=0
  while IFS= read -r -d $'\0' line; do
    a[i]="$line"
    ((i++))
  done < <(find "$dir" -name 'tmp.*' -maxdepth 1 -printf '%T@;%p\0' 2>/dev/null | sort -z -n -r)

  # check the folders we got, print out all the once we think are ok
  for ((i = $i - 1; i >= 0; i--)); do
    file="${a[$i]}"
    file="${file#*;}"
    file=`readlink -f $file`
    # make sure the cleaned name is still in /data/scratch (paranoia)
    fp=`echo $file | cut -d'/' -f1-3`
    if [ `echo $file | cut -d'/' -f1-3` != '/data/scratch' ]; then
      echo "ERROR: \"$file\" is not in /data/scratch" >> $log
    else
      si=`du -s "$file" | awk '{print $1}'`
      # echo "INFO: could remove $file to free up $si" >> $log
      echo "$si;$file"
    fi
  done
}

# there are some left-over directories that we can remove
# there are also some docker containers we can clean out
sweep () {
   # first remove invisible tmp directories - a directory is invisible if if does not contain info.json
   for u in `ls -d /data/scratch/tmp.*`; do 
      if [ ! -e $u/info.json ]; then
         echo "REMOVE: invisible directory $u\n" >> $log
         sudo \rm -f -R $u;
      fi; 
   done

   # next remove all archive data that do not have a reference in tmp anymore
   if hash realpath 2>/dev/null; then
     ls -d /data/scratch/tmp.*/INPUT | xargs realpath | sort | uniq > /tmp/tmpreferenced
     # we have to add the directories in waiting (in .arrived but not yet in tmp)
     # otherwise we would delete them by accident
     if [ "$(ls -A /data/scratch/.arrived)" ]; then
       ls -Ad /data/scratch/.arrived/* | cut -d' ' -f4 | xargs -i echo /data/scratch/archive/{} >> /tmp/tmpreferenced
     fi
     ls -d /data/scratch/archive/* > /tmp/inarchive
     notreferenced=`grep -v -f /tmp/tmpreferenced /tmp/inarchive`
     #echo "REMOVE: archive data not referenced in /data/scratch/tmp.* anymore \"$notreferenced\"" >> $log
     for u in $notreferenced; do
	 echo "REMOVE: archive not referenced $u" >> $log
         sudo \rm -f -R $u;
     done
     # I am not trusting this one yet
     #grep -v -f /tmp/tmpreferenced /tmp/inarchive | xargs sudo \rm -R -f 
   else
     echo "ERROR: could not remove non-referenced scans because realpath is not installed" >> $log
   fi

   # next remove all docker container that are un-named and not running
   old=`sudo docker ps -a | grep Exit | awk '{print $1}'`
   echo "REMOVE: exited docker containers \"$old\"" >> $log
   sudo docker ps -a | grep Exit | awk '{print $1}' | sudo xargs docker rm
   old=`sudo docker images -q --filter "dangling=true"`
   echo "REMOVE: dangling containers \"$old\"" >> $log
   sudo docker images -q --filter "dangling=true" | sudo xargs docker rmi
}

#mkdir -p /var/run/magickbox

# The following section takes care of not starting this script more than once 
# in a row. If for example it takes too long to run a single iteration this 
# will ensure that no second call to scrub is executed prematurely.
(
  flock -n 9 || exit 1
  # command executed under lock
  scrub
) 9>/data/.pids/scrubStorage.lock
