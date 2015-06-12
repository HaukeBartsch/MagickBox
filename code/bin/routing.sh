#!/usr/bin/env python

import sys, json, re, time
import logging
import os
import subprocess as sub

FORMAT = '%(asctime)-15s %(message)s'
logging.basicConfig(filename='/data/logs/routing.log',format=FORMAT,level=logging.DEBUG)
logging.info("Routing called")

def main(argv):
  if len(sys.argv) != 4:
     print "usage: <processing directory> <aetitle called> <aetitle caller>"
     logging.error("Error: input parameters don't work, see usage... ")
     sys.exit()
  WORKINGDIR=sys.argv[1]
  AETitleCalled=sys.argv[2]
  AETitleCaller=sys.argv[3]

  logging.info('CALLED routing with ' + WORKINGDIR + ' ' + AETitleCalled + ' ' + AETitleCaller)

  # read in the proc.json files to find out what the status of processing was
  # it depends on what the status was if routing will be performed
  try:
    proc_data = open(WORKINGDIR + '/proc.json')
    proc = json.load(proc_data)
    proc_data.close()
  except IOError:
    proc = []
    proc.insert(0,{})
    proc[0]['success'] = 'couldNotReadProcJSON'
    logging.warning("Could not read the proc file \"" + WORKINGDIR + "/proc.json\", only default routing using " + proc[0]['success'] + " is performed")

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
    logging.info("check route " + str(route) + " \"" + routingtable['routing'][route]['name'] + "\"");
    # is this route active?
    try:
        active = routingtable['routing'][route]['status']
    except KeyError:
        active = 1
    if active == 0:
      logging.warning("Inactive route")
      continue

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
        logging.info(" test if AETitleCalled \"" + AETitleCalled + "\" matches: AETitleIn \"" + routingtable['routing'][route]['AETitleIn'] + "\"")
        if reAETitleCalled.search(AETitleCalled):
          logging.info(" routing matches!")
          sendR1 = True
        else:
          logging.info(" routing does not match!")
          sendR1 = False
    except KeyError:
        logging.info(" This entry does not have AETitleIn, which is fine if we have an AETitleFrom")
    try:
        reAETitleCaller = re.compile(routingtable['routing'][route]['AETitleFrom'], re.IGNORECASE)
        logging.info(" test if AETitleCaller \"" + AETitleCaller + "\" matches: AETitleFrom \"" + routingtable['routing'][route]['AETitleFrom'] + "\"")
        if reAETitleCaller.search(AETitleCaller):
          logging.info(" routing matches!")
          sendR2 = True
        else:
          logging.info(" routing does not match!")
          sendR2 = False
    except KeyError:
        logging.info(" This entry does not have AETitleFrom, which is fine if we have an AETitleIn")

    send = sendR1 and sendR2
    if send == True:
        # now find out if the regular expression in proc[0]['success'] matches any key in send
        for endpoint in routingtable['routing'][route]['send']:
          for key in endpoint.keys():
            rePROCSUCCESS   = re.compile(key, re.IGNORECASE)
            logging.info("  Test if \"" + key + "\" (as a regular expression) matches \"" + proc[0]['success'] + "\").")
            if rePROCSUCCESS.search(proc[0]['success']):
              logging.info("  We found an endpoint \"" + key + "\" that matches \"" + proc[0]['success'] + "\" now send data to that endpoint.")
              try:
                AETitleSender = replacePlaceholders( endpoint[key]['AETitleSender'] )
                AETitleTo     = replacePlaceholders( endpoint[key]['AETitleTo'] )
                IP            = replacePlaceholders( endpoint[key]['IP'] )
                PORT          = replacePlaceholders( endpoint[key]['PORT'] )
                try:
                  BR        = endpoint[key]['break']
                except KeyError:
                  BR = 0
                try:
                  errorLOG = endpoint[key]['sendErrorAsDcm']
                except KeyError:
                  errorLOG = 0
                try:
                  which = endpoint[key]['which']
                except KeyError:
                  which = ""
              except KeyError:
                logging.warning("  Could not apply routing rule because one of the required entries is missing: " + endpoint[key])
                continue    

              if errorLOG != 0:
                workstr = "/bin/bash /data/code/bin/saveErrorAsDcm.sh \"" + WORKINGDIR + "/processing.log\" \"" + WORKINGDIR + "/INPUT\" \"" + WORKINGDIR + "/OUTPUT\" &"
                logging.info('  ROUTE: ' + workstr)
                os.system(workstr)    

              ROUTEDIRECTORY="/OUTPUT"
              if 'RouteDirectory' in routingtable['routing'][route].keys():
                logging.info('    Found RouteDirectory, use it to transfer specific sub-directory.')
                ROUTEDIRECTORY="/"+routingtable['routing'][route]['RouteDirectory']
                logging.info('    route directory: ' + ROUTEDIRECTORY)
              else:
                logging.info('    DID not find RouteDirectory key')

              OUTPUTDIRECTORY = WORKINGDIR + ROUTEDIRECTORY
              if which != "":
                logging.info('  Found which statement, look for specific DICOM files to send in ' + OUTPUTDIRECTORY + '...')
                OUTPUTDIRECTORY = filterDICOM( OUTPUTDIRECTORY, which )
                logging.info('  Instead of original OUTPUT send now files from: ' + OUTPUTDIRECTORY)

              workstr = "/usr/bin/gearman -h 127.0.0.1 -p 4730 -f bucket02 -- \"" + OUTPUTDIRECTORY + " " + IP + " " + PORT + " " + AETitleSender + " " + AETitleTo + "\" &"
              logging.info('  ROUTE: ' + workstr)
              try:
                try:
                  output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
                except sub.CalledProcessError:
                  logging.info('    send returned: \"' + output + "\"")
              except OSError:
                logging.info('    error executing gearman job (OSError)');

              if BR == 0:
                logging.info("  [break] stop here with mapping success entries against keys...")
                break
            else: 
              logging.info("  Key \"" + key + "\" does not match with \"" + proc[0]['success'] + "\".")
    # break now if we are asked to
    if BREAKHERE != 0:
      logging.info("  [break] rule indicated to break here")
      break
  logging.info("routing finished")


def replacePlaceholders( str ):
  global PARENTIP
  global PARENTPORT
  if str == "$me":
    return PARENTIP
  if str == "$port":
    return PARENTPORT
  return str

def filterDICOM( inputdir, which ):
  # check as well if any one of the which statements is true for this file
  # collect all dicom tags and query the file once only
  dicomKeys = []
  searchString = ""
  for w in which:
    for key in w.keys():
       dicomKeys.append(key)
       searchString = searchString + " +P " + key
      
  # create output directory
  workstr = '/bin/mktemp -d'
  try:
    try:
      output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
    except sub.CalledProcessError:
      logging.info('    mktemp returned: \"' + output + "\"")
  except OSError:
    logging.info('    error executing mktemp (OSError)');
  TEMP=output.rstrip()
  logging.info('    Write matching files to \"' + TEMP + '\"')

  count = 0
  for root, dirs, files in os.walk( inputdir ):
    for file in files:
      #logging.info('         check file ' + file)
      #if not os.path.isfile(os.path.join(root, file)):
      #  logging.info('         file ' + file + ' is not a DICOM file')
      #  continue
      # check if this file is a DICOM file
      workstr = "/usr/bin/dcmftest " + os.path.join(root, file);
      try:
        try:
          output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
        except sub.CalledProcessError:
          #logging.info('    dcmftest returned: \"' + output + "\" from : \"" + workstr + "\"")
          logging.info('    dcmftest said no to ' + file )
          continue
        if output.startswith("no"):
          logging.info('    dcmftest said no to ' + file )
          continue
      except OSError:
        logging.info('    error executing dcmftest (OSError)');
    
      workstr = "/usr/bin/dcmdump " + searchString + " " + os.path.join(root,file);
      try:
        try:
          output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
        except sub.CalledProcessError:
          logging.info('    dcmdump returned: \"' + output + "\" for " + workstr)
      except OSError:
        logging.info('    error executing dcmdump (OSError)');
      # grab the output as lines by dicomKeys
      dicomValues = []
      for line in output.split('\n'):
        val = re.split('[\[\]]', line)
        if len(val) > 2:
          dicomValues.append(val[1])
          #  logging.info('   FOUND value ' + val[1])
        else:
          if len(line) > 0:
            logging.info('   Error: cannot get value from line \"' + line + '\"')
            dicomValues.append("")
      # now walk through which to test the current values (dicomKeys, dicomValues)
      
      for w in which:
        # all values have to match in any of the which
        allMatch = True
        for k in w.keys():
          try:
            idx = dicomKeys.index(k)
          except ValueError:
            logging.info('    Error: tried to find ' + k + ' in list, does not exist')
            continue
          try:
            reK = re.compile(w[k], re.IGNORECASE)
          except re.error:
            logging.info('ERROR in Expression \"' + w[k] + '\" of routing rule ' + k)
            continue
          if not reK.search(dicomValues[idx]):
            allMatch = False
            break
        if allMatch == True:
          # copy file to output
          output = ""
          workstr = "/bin/ln -s " + os.path.join(root,file) + " " + os.path.join(TEMP, ("dicom%04d.dcm" % count));
          logging.info("       File " + os.path.join(root,file) + " matches which and will be send ")
          try:
            try:
              output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
            except sub.CalledProcessError:
              logging.info('    linking file with ' + workstr + ' failed: \"' + output + "\"")
          except OSError:
            logging.info('    error executing ln (OSError)');
          os.chmod(TEMP, 0755);
          
          break  
      count = count + 1
  logging.info('    ' + str(count) + ' files found by which')
  return TEMP

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
