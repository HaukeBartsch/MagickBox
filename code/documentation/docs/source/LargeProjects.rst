.. _LargeProjects:

*******************************************
How to process a large number of subjects
*******************************************

There are two ways to process large numbers of cases. Use the `new command line utility 'mb'`_Shell or follow the description below.

Lets assume that we have a directory with a larger number of DICOM datasets that we want to process. We will send the data to the MB and download the results. First load the data into OsiriX (MacOS) or use the dcmtk toolkit (http://dicom.offis.de) to send the DICOM data to the processing system::

   storescu +sd +r -nh -aet MySelf -aec ProcBucket <ip of MagickBox> <port of MagickBox> <single DICOM directory>

The call above will descend into sub-directories and keep going even if non-DICOM files are encountered. The receiving AE title "ProcBucket" will be used to select the processing stream. Only single subject data should be send to the system in this way as each send operation is interpreted as a command for processing the received data. The above line should therefore be used in a loop with some sleep interval between send operations if more than one session needs to be send.

In order to find out the status of the processing we can either use the web-interface provided by MB or we can use 'curl' together with 'jq' to automate the procedure. Lets assume that curl and jq are installed. We can get a list of sessions send from a specific machine (here ip44) by::

   curl http://<ip of MB>:2813/code/php/getScratch.php | jq '.[] | select(.AETitleCaller=="ip44" and .processingTime!="0")'

In order to count how many sessions are still in the pipeline for processing use::

   curl http://<ip of MB>:2813/code/php/getScratch.php | jq -c -M '.[] | select(.AETitleCaller=="ip44" and .processingTime=="0")' | wc -l

In order to download the OUTPUT directory of a processed session we need to get the scratchdir and pid information for each finished session::

   fileList=`curl <ip of MB>:2813/code/php/getScratch.php | jq '.[] | select(.AETitleCaller=="ip44" and .processingTime!="0")' | jq '{"scratchdir": .scratchdir, "pid": .pid}'`

We can now download each finished session as a zip file into a separate directory::

   echo $fileList | jq -c -M . | while read line; do sc=`echo $line | cut -d'"' -f4`; d=`echo $line | cut -d'"' -f8`; mkdir -p "$d"; cd $d; curl -o ${d}.zip http://<ip of MB>:2813/code/php/getOutputZip.php?folder=$sc; cd ..; done

In order to delete processed scans use the same mechanism as above::

   echo $fileList | jq -c -M . | while read line; do sc=`echo $line | cut -d'"' -f4`; d=`echo $line | cut -d'"' -f8`; mkdir -p "$d"; cd $d; curl http://<ip of MB>:2813/code/php/deleteStudy.php?scratchdir=$sc; cd ..; done

