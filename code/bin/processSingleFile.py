#!/usr/bin/env python
"""
Create a daemon process that listens to send messages and reads a DICOM file,
extracts the header information and creates a Study/Series symbolic link structure.
"""

import sys, os, time, atexit, stat
import dicom, json, re
from signal import SIGTERM
from dicom.filereader import InvalidDicomError


class Daemon:
        """
        A generic daemon class.
        
        Usage: subclass the Daemon class and override the run() method
        """
        def __init__(self, pidfile, stdin='/dev/null', stdout='/dev/null', stderr='/dev/null'):
                    self.stdin    = stdin
                    self.stdout   = stdout
                    self.stderr   = stderr
                    self.pidfile  = pidfile
                    self.pipename = '/tmp/.processSingleFilePipe'
                    
        def daemonize(self):
                    """
                    do the UNIX double-fork magic, see Stevens' "Advanced
                    Programming in the UNIX Environment" for details (ISBN 0201563177)
                    http://www.erlenstar.demon.co.uk/unix/faq_2.html#SEC16
                    """
                    try:
                                pid = os.fork()
                                if pid > 0:
                                            # exit first parent
                                            sys.exit(0)
                    except OSError, e:
                                sys.stderr.write("fork #1 failed: %d (%s)\n" % (e.errno, e.strerror))
                                sys.exit(1)

                    # decouple from parent environment
                    os.chdir("/")
                    os.setsid()
                    os.umask(0)
                
                    # do second fork
                    try:
                                pid = os.fork()
                                if pid > 0:
                                            # exit from second parent
                                            sys.exit(0)
                    except OSError, e:
                                sys.stderr.write("fork #2 failed: %d (%s)\n" % (e.errno, e.strerror))
                                sys.exit(1)

                    # redirect standard file descriptors
                    sys.stdout.flush()
                    sys.stderr.flush()
                    #si = file(self.stdin, 'r')
                    #so = file(self.stdout, 'a+')
                    #se = file(self.stderr, 'a+', 0)
                    #os.dup2(si.fileno(), sys.stdin.fileno())
                    #os.dup2(so.fileno(), sys.stdout.fileno())
                    #os.dup2(se.fileno(), sys.stderr.fileno())

                    # write pidfile
                    atexit.register(self.delpid)
                    pid = str(os.getpid())
                    file(self.pidfile,'w+').write("%s\n" % pid)
                    
        def delpid(self):
                    os.remove(self.pidfile)

        def delpipe(self):
                    os.remove(self.pipename)
                            
        def start(self):
                    """
                    Start the daemon
                    """
                    # Check for a pidfile to see if the daemon already runs
                    try:
                                pf = file(self.pidfile,'r')
                                pid = int(pf.read().strip())
                                pf.close()
                    except IOError:
                                pid = None
                                
                    if pid:
                            message = "pidfile %s already exist. Daemon already running?\n"
                            sys.stderr.write(message % self.pidfile)
                            sys.exit(1)
                            
                    # Start the daemon
                    print(' start the daemon')
                    self.daemonize()
                    print ' done'
                    self.run()

        def send(self,arg):
                    """
                    Send a message to the daemon via pipe
                    """
                    # open a named pipe and write to it
                    if stat.S_ISFIFO(os.stat(self.pipename).st_mode):
                            try:
                                    wd = open(self.pipename, 'w')
                                    wd.write(arg + "\n")
                                    wd.flush()
                                    wd.close()
                            except IOError:
                                    print 'Error: could not open the pipe %s' % self.pipename
                    else:
                            sys.stderr.write(self.pipename)
                            sys.stderr.write("Error: the connection to the daemon does not exist\n")
                            sys.exit(1)

        def stop(self):
                    """
                    Stop the daemon
                    """
                    # Get the pid from the pidfile
                    try:
                            pf = file(self.pidfile,'r')
                            pid = int(pf.read().strip())
                            pf.close()
                    except IOError:
                            pid = None
                            
                    if not pid:
                            message = "pidfile %s does not exist. Daemon not running?\n"
                            sys.stderr.write(message % self.pidfile)
                            return # not an error in a restart
                                
                    # Try killing the daemon process
                    try:
                                while 1:
                                            os.kill(pid, SIGTERM)
                                            time.sleep(0.1)
                    except OSError, err:
                                err = str(err)
                                if err.find("No such process") > 0:
                                            if os.path.exists(self.pidfile):
                                                        os.remove(self.pidfile)
                                                        os.remove(self.pipename)
                                else:
                                            print str(err)
                                            sys.exit(1)
                                                        
        def restart(self):
                    """
                    Restart the daemon
                    """
                    self.stop()
                    self.start()
                    
        def run(self):
                    """
                    You should override this method when you subclass Daemon. It will be called after the process has been
                    daemonized by start() or restart().
                    """


class ProcessSingleFile(Daemon):
        def init(self):
                    self.classify_rules    = 0
                    self.rulesFile = '/data/code/bin/classifyRules.json'
                    if os.path.exists(self.rulesFile):
                            with open(self.rulesFile,'r') as f:
                                    self.classify_rules = json.load(f)
                    else:
                            print "Warning: no /data/code/bin/classifyRules.json file could be found"
 
        def classify(self,dataset,data):
                # read the classify rules
                if self.classify_rules == 0:
                        print "Warning: no classify rules found in %s, ClassifyType tag will be empty" % self.rulesFile
                        return ""
                for rule in range(len(self.classify_rules)):
                        t = self.classify_rules[rule]['type']
                        ok = True
                        for entry in range(len(self.classify_rules[rule]['rules'])):
                                r = self.classify_rules[rule]['rules'][entry]
                                # check if this regular expression matches the current type t
                                if len(r['tag']) == 1:
                                        v = data[r['tag'][0]]
                                elif len(r['tag']) == 2:
                                        v = dataset[int(r['tag'][0],0), int(r['tag'][1],0)].value
                                elif len(r['tag']) == 3:
                                        v = dataset[int(r['tag'][0],0), int(r['tag'][1],0)].value[int(r['tag'][2],0)]
                                else:
                                        print("Error: tag with unknown structure, should be 1, 2, or 3 entries in array")
                                if not "operator" in r:
                                        r["operator"] = "regexp"  # default value
                                op = r["operator"]
                                if  op == "regexp":
                                        pattern = re.compile(r['value'])
                                        if not pattern.search(v):
                                           # this pattern failed, fail the whole type and continue with the next
                                           ok = False
                                           break
                                elif op == "==":
                                        if not float(r['value']) == float(v):
                                           ok = False
                                           break
                                elif op == "!=":
                                        if not float(r['value']) != float(v):
                                           ok = False
                                           break
                                elif op == "<":
                                        if not float(r['value']) > float(v):
                                           ok = False
                                           break
                                elif op == ">":
                                        if not float(r['value']) < float(v):
                                           ok = False
                                           break
                                elif op == "exist":
					if not tagthere:
                                           ok = False
                                           break
                                elif op == "notexist":
					if tagthere:
                                           ok = False
                                           break
                                else:
                                        ok = False
                                        break
                                           
                        # ok nobody failed, this is it
                        if ok:
                          return t
                return ""
                                
        def run(self):
                try:
                        os.mkfifo(self.pipename)
                        atexit.register(self.delpipe)
                except OSError:
                        print 'OSERROR on creating the named pipe %s' % self.pipename
                        pass
                try:
                        rp = open(self.pipename, 'r')
                except OSError:
                        print 'Error: could not open named pipe for reading commands'
                        sys.exit(1)
                        
                while True:
                        response = rp.readline()[:-1]
                        if not response:
                                time.sleep(0.1)
                                continue
                        else:
                                #print 'Process: %s' % response
                                try:
                                        dataset = dicom.read_file(response)
                                except IOError:
                                        print("Could not find file:", response)
                                        continue
                                except InvalidDicomError:
                                        print("Not a DICOM file: ", response)
                                        continue
                                indir = '/data/scratch/archive/'
                                if not os.path.exists(indir):
                                        print("Error: indir does not exist")
                                        continue
                                outdir = '/data/scratch/views/raw'
                                if not os.path.exists(outdir):
                                        os.makedirs(outdir)
                                infile = os.path.basename(response)        
                                fn = os.path.join(outdir, dataset.StudyInstanceUID, dataset.SeriesInstanceUID)
                                if not os.path.exists(fn):
                                        os.makedirs(fn)
                                fn2 = os.path.join(fn, dataset.SOPInstanceUID)
                                if not os.path.isfile(fn2):
                                  os.symlink(response, fn2)
                                else:
                                  continue # don't  do anything because the file exists already
                                # lets store some data in a series specific file
                                fn3 = os.path.join(outdir, dataset.StudyInstanceUID, dataset.SeriesInstanceUID) + ".json"
                                data = { 'StudyInstanceUID' : dataset.StudyInstanceUID,
                                         'SeriesInstanceUID' : dataset.SeriesInstanceUID,
                                         'PatientID' : dataset.PatientID,
                                         'PatientName' : dataset.PatientName,
                                         'StudyDate' : dataset.StudyDate,
                                         'StudyDescription' : dataset.StudyDescription,
                                         'SeriesDescription': dataset.SeriesDescription,
                                         'EchoTime' : str(dataset.EchoTime),
                                         'RepetitionTime' :str(dataset.RepetitionTime),
                                         'NumFiles' : str(0)
                                }
                                try:
                                         data['Private0019_10BB'] = str(dataset[0x0019,0x10BB].value)
                                except KeyError:
                                        pass
                                try:
                                        vals = dataset[0x0043,0x1039].value
                                        data['Private0043_1039'] = vals
                                except KeyError:
                                        pass
                                if os.path.exists(fn3):
                                        with open(fn3, 'r') as f:
                                                data = json.load(f)
                                data['StudyInstanceUID'] = dataset.StudyInstanceUID
                                data['NumFiles'] = str( int(data['NumFiles']) + 1 )
                                # do this last, it could use values in data for classification
                                data['ClassifyType'] = self.classify(dataset, data)
                                with open(fn3,'w') as f:
                                        json.dump(data,f,indent=2,sort_keys=True)
                rp.close()

# There are two files that make this thing work, one is the .pid file for the daemon
# the second is the named pipe in /tmp/.processSingleFile
#  Hauke,    July 2015               
if __name__ == "__main__":
        daemon = ProcessSingleFile('/data/.pids/processSingleFile.pid')
        daemon.init()
        if len(sys.argv) == 2:
                if 'start' == sys.argv[1]:
                        daemon.start()
                elif 'stop' == sys.argv[1]:
                        daemon.stop()
                elif 'restart' == sys.argv[1]:
                        daemon.restart()
                else:
                        print "Unknown command"
                        sys.exit(2)
                sys.exit(0)
        elif len(sys.argv) == 3:
                if 'send' == sys.argv[1]:
                        daemon.send(sys.argv[2])
                sys.exit(0)
        else:
                print "Process a single DICOM file fast using a daemon process that creates symbolic links."
                print "Use 'start' to start the daemon in the background. Send file names for processing using 'send'."
                print "Usage: %s start|stop|restart|send" % sys.argv[0]
                sys.exit(2)
