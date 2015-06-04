.. _BucketAPI:

****************
Create a bucket 
****************

Note: These instructions should work on Linux, MacOS and Windows (cygwin) systems with docker or boot2docker installed.

Processing functionality is added as docker containers that contain a basic structure of files. Name your container (bucket) using lower-case characters and numbers only. Create one using the buckets script::

 wget https://raw.githubusercontent.com/HaukeBartsch/MagickBox/master/code/bin/buckets
 chmod gou+rx buckets
 ./buckets create mytestbucket

This will create a docker image (mytestbucket) with two special files. The first file describes the bucket. Edit this file by starting the bucket with an interactive shell and by editing the file using vi::

 docker run -i -t mytestbucket /bin/bash
 vi /root/storage/info.json

Set the application entity title (AETitle) of the bucket to be something short and unique. This is later used to address this processing bucket. Remember to use a second terminal to commit your changes after you edited any file inside the bucket::

 docker commit <running image id> mytestbucket

Only changes that are commited will be available the next time the bucket runs.

Now is a good time to install a program for data processing into the bucket. The program will receive input data in one directory and output data in another directory. The bucket container is currently based on ubuntu so you can install programs using apt-get::

 docker run -i -t mytestbucket /bin/bash
 apt-get update

Follow install instructions for a 64bit Linux and you should be able to add your software to the bucket. Don't forget to commit the changes.

A second file will call your installed program with /input and /output as two arguments::

 docker run -i -t mytestbucket /bin/bash
 vi /root/work.sh

Test your bucket by specifying an input and output directory (this will be done by MagickBox later)::

 docker run -i -t -v "<path to input data>":/input -v "<path to ouput directory>":/output mytestbucket /bin/bash
 /root/work.sh /input /output

After a successful run you should see your results appear in the /output folder.

Currently the mb program can be used to send arbitrary data to a MagickBox bucket. DICOM data can also be send directly to the DICOM node inside MagickBox using a PACS system, OsiriX or the dcmtk tools.

Installation
============

After developing a bucket and successful local testing it can be integrated into MagickBox. Start by creating a file that represents the bucket::

 docker export <id of running docker container> > mytestbucket.tar

Transfer this file to your MagickBox and import it there::
 
 cat mytestbucket.tar | docker import - mytestbucket
 /data/code/bin/buckets install mytestbucket

Buckets will try to query your mytestbucket container and reads the AETitle from the /root/storage/info.json file. This AETitle is used to create a directory for the bucket in /data/streams/bucket<AETitle>. If successful the install call will also start a worker process for your processing bucket. If you send data to the system using your AETitle to address your bucket the processing should start. A log-file /data/logs/bucket<AETitle>.log will contain the output of MagickBox when it tries to call your bucket.
