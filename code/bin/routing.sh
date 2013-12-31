#!/usr/bin/env python

import sys, json, re
import logging
import os

logging.basicConfig(filename='/data/logs/routing.log',level=logging.DEBUG)
logging.info("Routing called")

def main(argv):
  if len(sys.argv) != 4:
     print "usage: <processing directory> <aetitle called> <aetitle caller>"
     logging.error("Error: input parameters don't work, see usage... \"" + sys.argv + "\"")
     sys.exit()
  WORKINGDIR=sys.argv[1]
  AETitleCalled=sys.argv[2]
  AETitleCaller=sys.argv[3]

  # read in the proc.json files to find out what the status of processing was
  # it depends on what the status was if routing will be performed
  try:
	proc_data = open(WORKINGDIR + '/proc.json')
  	proc = json.load(proc_data)
  	proc_data.close()
  except IOError:
    logging.warning("Could not read the proc file for " + WORKINGDIR + "/proc.json, only default routing is performed")
    proc = []
    proc.insert(0,{})
    proc[0]['success'] = 'couldNotReadProcJSON'

  # read in the routing table, something like this would work:
  #  {u'AETitleFrom': u'HAUKETEST',
  #   u'AETitleIn': u'ProcRSI',
  #   u'send': [{u'failed': {u'AETitleSender': u'me',
  #                      u'AETitleTo': u'PACS',
  #                      u'IP': u'192.168.0.1',
  #                      u'PORT': u'403'},
  #          u'partial': {u'AETitleSender': u'me',
  #                       u'AETitleTo': u'PACS',
  #                       u'IP': u'192.168.0.1',
  #                       u'PORT': u'403'},
  #          u'success': {u'AETitleSender': u'ROUTING',
  #                       u'AETitleTo': u'PACS',
  #                       u'IP': u'137.110.172.43',
  #                       u'PORT': u'11113'}}]}

  try:
  	routingtable_data = open('/data/code/bin/routing.json')
  	routingtable = json.load(routingtable_data)
  	routingtable_data.close()
  except IOError:
  	logging.warning("Error: Could not read /data/code/bin/routing.json, no routing is performed")
  	sys.exit()

  for route in range(len(routingtable['routing'])):
    #pprint(routingtable['routing'][route])
    sendR1=True
    sendR2=True
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

    try:
        reAETitleCalled = re.compile(routingtable['routing'][route]['AETitleIn'], re.IGNORECASE)
        logging.info("test if " + AETitleCalled + " routing matches: " + routingtable['routing'][route]['AETitleIn'])
        if reAETitleCalled.search(AETitleCalled):
          logging.info("routing matches!")
          sendR1 = True
        else:
          logging.info("routing does not match!")
          sendR1 = False
    except KeyError:
        logging.info("This entry does not have AETitleFrom")
    try:
        reAETitleCaller = re.compile(routingtable['routing'][route]['AETitleFrom'], re.IGNORECASE)
        logging.info("test if " + AETitleCaller + " routing matches: " + routingtable['routing'][route]['AETitleFrom'])
        if reAETitleCaller.search(AETitleCaller):
          logging.info("routing matches!")
          sendR2 = True
        else:
          logging.info("routing does not match!")
          sendR2 = False
    except KeyError:
        logging.info("This entry does not have AETitleFrom")

    send = sendR1 and sendR2
    if send == True:
        # now find out if the regular expression in proc[0]['success'] matches any key in send
        for endpoint in routingtable['routing'][route]['send']:
        	for key in endpoint.keys():
        		rePROCSUCCESS   = re.compile(key, re.IGNORECASE)
        		logging.info("Test if \"" + key + "\" (as a regular expression) matches \"" + proc[0]['success'] + "\" (" + proc[0]['message'] + ").")
        		if rePROCSUCCESS.search(proc[0]['success']):
					logging.info("We found an endpoint \"" + key + "\" that matches \"" + proc[0]['success'] + "\" now send data to that endpoint...")
					try:
						AETitleSender = replacePlaceholders( endpoint[key]['AETitleSender'] )
						AETitleTo     = replacePlaceholders( endpoint[key]['AETitleTo'] )
						IP            = replacePlaceholders( endpoint[key]['IP'] )
						PORT          = replacePlaceholders( endpoint[key]['PORT'] )
						try:
							BR        = endpoint[key]['break']
						except KeyError:
							BR = 0
					except KeyError:
						logging.warning("Could not apply routing rule because one of the required entries is missing: " + endpoint[key])
						continue

					workstr = "/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -- \"" + WORKINGDIR + "/OUTPUT " + IP + " " + PORT + " " + AETitleSender + " " + AETitleTo + "\" &"
					logging.info('ROUTE: ' + workstr)
					os.system(workstr)
					if BR == 0:
						logging.info("[break] stop here with mapping success entries against keys...")
						break
        		else: 
        		  logging.info("Key \"" + key + "\" does not match with \"" + proc[0]['success'] + "\".")
		# break now if we are asked to
		if BREAKHERE != 0:
                        logging.info("[break] rule indicated to break here")
			break
	logging.info("routing finished (route " + str(route) + ")")


def replacePlaceholders( str ):
	global PARENTIP
	global PARENTPORT
	if str == "$me":
		return PARENTIP
	if str == "$port":
		return PARENTPORT
	return str

#
# read in the machine's name and port and save as global variables
#
PARENTIP=""
PARENTPORT=""
myself_file = open('/data/code/setup.sh')
myself = myself_file.read()
myself_file.close()
myself = myself.split(";")
for keyvaluestr in myself:
	keyvalue = keyvaluestr.split("=")
	if len(keyvalue) == 2:
		if keyvalue[0].strip() == "PARENTIP":
			PARENTIP=keyvalue[1].strip()
		if keyvalue[0].strip() == "PARENTPORT":
			PARENTPORT=keyvalue[1].strip()

if PARENTIP == "":
  logging.info("Warning: could not read the machine's IP")
if PARENTPORT == "":
  logging.info("Warning: could not read the machine's PORT")

if __name__ == "__main__":
  main(sys.argv[1:])
