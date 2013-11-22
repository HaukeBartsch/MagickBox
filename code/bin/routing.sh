#!/bin/bash
. ticktick.sh

WORKINGDIR=$1
AETitleIn=$2
AETitleFrom=$3
AETitleCalled=$4
AETitleCaller=$5

# File
DATA=`cat /data/code/bin/routing.json`

tickParse "$DATA"

echo "read routing information: $DATA" >> /data/logs/routing.log
echo ``routing[0][AETitleIn]`` >> /data/logs/routing.log

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
