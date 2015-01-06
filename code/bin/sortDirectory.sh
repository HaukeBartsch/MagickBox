#!/usr/bin/env python

#
# Sorting should be done on demand
#   "Give me a directory with the first T1."
#   "Give me a directory with a perfusion series."
#

import sys, json, re, time
import logging
import os
import subprocess as sub

logging.basicConfig(filename='/data/logs/sortDirectory.log',level=logging.DEBUG)
now = time.strftime("%c")
logging.info("%s sortDirectory called" % now)

def main(argv):
  if len(sys.argv) != 3:
     print "usage: <processing directory> <requested type>"
     print "       test with  ./sortDirectory.sh . \"T1\""
     logging.error("Error: input parameters don't work, see usage... ")
     sys.exit()
  WORKINGDIR=sys.argv[1]
  TYPE=sys.argv[2]

  logging.info('CALLED sortDirectory for ' + WORKINGDIR + ' look for ' + TYPE)

  try:
    sortingrules_data = open('/data/code/bin/sortingRules.json')
    rules = json.load(sortingrules_data)
    sortingrules_data.close()
  except IOError:
    logging.warning("Error: Could not read /data/code/bin/sortingRules.json, no sorting is performed")
    print "Error: could not read the rules"
    sys.exit()

  # check if we have a rule for TYPE
  rule = []
  for r in rules:
    if TYPE == r['name']:
      rule = r
  
  if rule == []:  
    logging.error("Error: type " + TYPE + " could not be found in sortingRules.json")
    print "Error: find that type in the rules"
    sys.exit()
  print "Info: found " + rule['name'] + " rule..."

  # extract all measures for the current rule, add to measures
  measures := { 'name': 

  # we want to read in all files (TODO: read in information from non-DICOM files as well)
  count = 0
  for root, dirs, files in os.walk( WORKINGDIR ):
    for file in files:
      workstr = "/usr/bin/dcmftest " + os.path.join(root, file);
      try:
        try:
          output = sub.check_output( workstr, stderr=sub.STDOUT, shell=True )
        except sub.CalledProcessError:
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




  # we want to sort them based on all the rules, try each rule, if we get some data that fit that rule, create the directory tree for them

  # we want to save a directory tree with symbolic links that identifies which series is which
  # for example we should have all T1 datasets in there, sorted by creation date/time, all BOLD, etc.


  logging.info("sortDirectory finished")


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
          #logging.info("       File " + os.path.join(root,file) + " matches which and will be send ")
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
  logging.info('    ' + count + ' files found by which')
  return TEMP


if __name__ == "__main__":
  main(sys.argv[1:])
