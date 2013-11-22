#!/usr/bin/env python

import sys, json
from pprint import pprint

def main(argv):
  if len(sys.argv) != 4:
     print "usage: <processing directory> <aetitle called> <aetitle caller>"
     sys.exit()
  WORKINGDIR=sys.argv[1]
  AETitleCalled=sys.argv[2]
  AETitleCaller=sys.argv[3]

  routingtable_data = open('/data/code/bin/routing.json')
  routingtable = json.load(routingtable_data)
  routingtable_data.close()
  pprint(routingtable)

  #try:
  #  idx = header.index(c)
  #except ValueError:
  #  print "Error: column does not exist"
  #  sys.exit(-1)

  #all = list( reader )
  #try:
  #  print all[s][idx]
  #except IndexError:
  #  print "Error: step does not exist"
  #  sys.exit(-1)

if __name__ == "__main__":
  main(sys.argv[1:])


#!/bin/bash
. ticktick.sh

if [ $# -ne 3 ]
then
   echo "usage: routing.sh <processing directory> <aetitle called> <aetitle caller> "
   exit 1
fi


WORKINGDIR=$1
AETitleCalled=$2
AETitleCaller=$3

# File
DATA=`cat /data/code/bin/routing.json`

tickParse "$DATA"

echo "read routing information: $DATA" >> /data/logs/routing.log
echo "one route: ``routing[0][AETitleIn]`` " >> /data/logs/routing.log

numRoutes=``routing.length()``
echo "number of routes $numRoutes" >> /data/logs/routing.log
for route in ``routing.items()``; do
  AETitleIn=``route.AETitleIn``
  AETitleFrom=``route.AETitleFrom``
  # does this match with our calling AETitle?
  echo "TRY to match $AETitleIn, $AETitleFrom to $AETitleCalled, $AETitleCaller" >> /data/logs/routing.log

  if [[ $AETitleIn =~ $AETitleCalled ]]
  then
     echo "FOUND matching rule $AETitleIn, $AETitleCalled" >> /data/logs/routing.log
  fi
  if [[ $AETitleFrom =~ $AETitleCaller ]]
  then
     echo "FOUND matching rule $AETitleFrom, $AETitleCaller" >> /data/logs/routing.log
  fi
done
