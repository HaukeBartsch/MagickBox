.. _BucketAPI:

*******************
Bucket development
*******************

Note: These instructions should work on Linux, MacOS and Windows (cygwin) systems that have docker installed.

A bucket is developed as a docker container (bucket) with some special files to support the MagickBox processing stream.

Name your bucket using lower-case characters and numbers only. Create one by downloading the "buckets" script::

 wget https://raw.githubusercontent.com/HaukeBartsch/MagickBox/master/code/bin/buckets
 chmod gou+rx buckets
 ./buckets create mytestbucket

This will create "mytestbucket" as an empty container with some MagickBox special sauce. One file describes your bucket. Edit this file by starting the bucket and by editing the file using the built-in editor vi::

 ./buckets open mytestbucket
 vi /root/storage/info.json

Set the application entity title (AETitle) entry to be something short and unique. This string is later used to address this processing bucket. Store your changes using a second terminal (commit your changes after you edited any file inside the bucket)::

 docker ps
 docker commit <running image id> mytestbucket

Now install your program for data processing in the bucket. The program will receive input data in an /input directory and it can produce output data in /output. The bucket is based on ubuntu so you can install many programs using apt-get.

As an entry point MagickBox will call a single script inside your bucket. Edit this script and have it execute your program given the input and output directories::

 ./bucket open mytestbucket
 vi /root/work.sh

Test your bucket by specifying an input and output directory (this will emulate tbe work done by MagickBox later)::

 docker run -i -t -v "<path to input data>":/input -v "<path to output directory>":/output mytestbucket /bin/bash
 /root/work.sh /input /output
 exit

After a successful run you should see your results appear in the directory specified as output folder.

Optionally you can also include a plugin that extracts measurements from your output files. Measures exported this way will be available inside MagickBox. Useful measures include demographic information or for example volumes of interest. An example plugin file is included with your bucket. Edit the file by::

 ./bucket open mytestbucket
 vi /root/storage/db-plugin.code


Installation
============

After developing a bucket and successful local testing it can be integrated into a MagickBox machine. If you don't do your development inside MagickBox start by creating a tar-file that represents the content of your bucket::

 docker export <id of running docker container> > mytestbucket.tar

Transfer this file to one or several MagickBox machines and import the bucket using docker followed by "buckets install"::
 
 cat mytestbucket.tar | docker import - mytestbucket
 /data/code/bin/buckets install mytestbucket

The buckets-script will query your mytestbucket container and read the AETitle from the /root/storage/info.json file. The AETitle is used to create a MagickBox bucket directory in /data/streams/bucket<AETitle>. If successful the installer will also start a worker process for your processing bucket. If you now send data to the system using your AETitle to address your bucket the processing should start (see the mb tool). A log-file /data/logs/bucket<AETitle>.log will contain the output of MagickBox when it tries to call your bucket. If your bucket produces some outputs they will be displayed as the processing.log.
