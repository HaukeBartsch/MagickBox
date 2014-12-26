#!/bin/bash

# This script can be started by cron (something like every 10 minutes should work).
# It can be run several times, only the first run will actually work. Followup runs
# will fail until the first run is finished.

# percentage value of hard drive filled when we have to do something
highwaterborder=90
# we remove directories until we hit this border (should always be smaller)
lowwaterborder=80
# directory to scrub (look for tmp.* files only)
dir=/data/scratch
# location of log file
log=/data/logs/scrubStorage.log
# just checking or really removing stuff?
enable=0

scrub () {
  echo "START SCRUBBING `date`" >> $log
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
       su nice -n 3 /bin/rm -f -R "$f"
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

# The following section takes care of not starting this script more than once 
# in a row. If for example it takes too long to run a single iteration this 
# will ensure that no second call to scrub is executed prematurely.
(
  flock -n 9 || exit 1
  # command executed under lock
  scrub
) 9>/data/.pids/scrubStorage.lock
