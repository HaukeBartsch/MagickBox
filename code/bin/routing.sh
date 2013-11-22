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
  #pprint(routingtable)

  for route in range(len(routingtable)):
    pprint(routingtable[route])

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
