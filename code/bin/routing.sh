#!/usr/bin/env python

import sys, json, re
from pprint import pprint
import logging
from subprocess import call

def main(argv):
  logging.basicConfig(filename='/data/logs/routing.log',level=logging.DEBUG)
  logging.info("Routing called")
  if len(sys.argv) != 4:
     print "usage: <processing directory> <aetitle called> <aetitle caller>"
     sys.exit()
  WORKINGDIR=sys.argv[1]
  AETitleCalled=sys.argv[2]
  AETitleCaller=sys.argv[3]

  # read in the proc.json files to find out what the status of processing was
  try:
	proc_data = open(WORKINGDIR + '/proc.json')
  	proc = json.load(proc_data)
  	proc_data.close()
  except IOError:
    logging.warning("Could not read the proc file for " + WORKINGDIR + "/proc.json, only default routing is performed")

  # read in the routing table
  try:
  	routingtable_data = open('/data/code/bin/routing.json')
  	routingtable = json.load(routingtable_data)
  	routingtable_data.close()
  except IOError:
  	logging.warning("Error: Could not read /data/code/bin/routing.json, no routing is performed")
  	sys.exit()

  reAETitleCalled = re.compile(AETitleCalled, re.IGNORECASE)
  reAETitleCaller = re.compile(AETitleCaller, re.IGNORECASE)
  rePROCSUCCESS = re.compile(proc['success'], re.IGNORECASE)
  for route in range(len(routingtable['routing'])):
    #pprint(routingtable['routing'][route])
    send=False
    try:
        AETitleFrom = routingtable['routing'][route]['AETitleFrom']
    except KeyError:
        AETitleFrom = -1 # no match
    try:
        AETitleIn = routingtable['routing'][route]['AETitleIn']
    except KeyError:
        AETitleIn = -1 # no match
    try:
        BREAKHERE = routingtable['routing'][route]['break']
    except KeyError:
        BREAKHERE = 0 # no match
    if AETitleFrom != -1 and reAETitleCalled.search(routingtable['routing'][route]['AETitleFrom']):
    	logging.info("routing matches: " + routingtable['routing'][route]['AETitleFrom'])
    	send = True
    elif AETitleIn != -1 and reAETitleCaller.search(routingtable['routing'][route]['AETitleIn']):
    	logging.info("routing matches: " + routingtable['routing'][route]['AETitleIn'])
    	send = True
    if send == True:
        # now find out if the regular expression in proc['success'] matches any key in send
        for endpoint in routingtable['routing'][route]['send']:
        	for key in endpoint.keys():
        		if rePROCSUCCESS.search(key):
					logging.info("We found an endpoint \""+key+"\" that matches \""+proc['success'] + "\" now send data to that endpoint...")
					try:
						AETitleSender = endpoint[key]['AETitleSender']
						AETitleTo = endpoint[key]['AETitleTo']
						IP = endpoint[key]['IP']
						PORT = endpoint[key]['PORT']
					except KeyError:
						logging.warning("Could not apply routing rule because one of the required entries is missing: " + endpoint[key])
						continue
					call(["/usr/bin/gearman", "-h", "127.0.0.1", "-p", "4730", "-f", "bucket02", "--", 
						"\""+ WORKINGDIR+"/OUTPUT " + IP + " " + PORT + " " + AETitleSender + " " + AETitleTo + "\""])
		# break now if we are asked to
		if BREAKHERE != 0:
			break

  logging.info("routing finished")
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
