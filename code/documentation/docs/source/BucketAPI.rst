.. _BucketAPI:

*******************
Bucket development
*******************

A bucket is a portable light-weight container based (on docker) for MR image analysis pipelines. A bucket runs in the same way a program is executed. If data is available the bucket will start, perform its function and quit. This page explains the 'buckets' development program that is used to create, run and install buckets.

Note: The instructions to develop a bucket should work on Linux, MacOS and Windows (cygwin) systems that have docker or boot2docker installed.


Create
=======

Name your bucket using lower-case characters and numbers only. Create one by downloading the "buckets" script, make it executable and run its 'create' command::

 wget https://raw.githubusercontent.com/HaukeBartsch/MagickBox/master/code/bin/buckets
 chmod gou+rx buckets
 ./buckets create mytestbucket

This will create "mytestbucket" as an almost empty bucket with some MagickBox special sauce. The bucket contains already its own documentation. Edit it by starting the bucket (open) and change the contained info.json file using the built-in editor vi (or install your own editor of choice using apt-get)::

 ./buckets open mytestbucket
 vi /root/storage/info.json

Set the application entity title (AETitle) to be something short and unique. This string is later used to address this processing bucket. Store your changes using a second terminal (remember to commit your changes after you edited any file inside the bucket)::

 docker ps
 docker commit <running image id> mytestbucket

Now it is time to install your program into the bucket. The program will receive input data in an /input directory and it can produce output data in /output. The bucket is based on ubuntu so you can install a large number of existing programs simply by calling apt-get.

To link up your program and the MagickBox processing entry point /root/work.sh edit that script and have it execute your program given the input and output directories::

 ./bucket open mytestbucket
 vi /root/work.sh

The 'open' command will also create a link to your local directory inside the bucket. If your program is not avialable from one of the apt repositories you can copy the files into your local directory. That directory is available inside the bucket as /local/. Only use this connection to copy data into the bucket during installation of your program. The directory will not be available if the bucket runs inside the MagickBox environment.

Test
=====

Test your bucket by specifying an input and output directory for the 'run' command (this will emulate tbe work done by MagickBox later)::

 ./bucket run mytestbucket <input directory> <output directory>

After a successful run you should see your results appear in the directory you specified as the output folder. This is also a great way to locally run a computation on a limited number of cases.

Optionally you can include a plugin that extracts measurements from your output files. Measures exported this way will be available to MagickBox. Useful measures include demographic information or for example measures for volumes of interest. An example plugin file is included with your bucket. Edit the file by::

 ./bucket open mytestbucket
 vi /root/storage/db-plugin.code


Install
========

After developing a bucket and successful local testing it can be integrated into a MagickBox machine. If you don't do your development inside MagickBox start by creating a tar-file that represents the content of your bucket::

 docker export <id of running docker container> > mytestbucket.tar

Copy this file to a MagickBox machine and import the bucket using docker followed by "buckets install"::
 
 cat mytestbucket.tar | docker import - mytestbucket
 /data/code/bin/buckets install mytestbucket

The buckets-script will query your mytestbucket container and read the AETitle from the /root/storage/info.json file. The AETitle is used to create a MagickBox bucket directory in /data/streams/bucket<AETitle>. If successful the installer will also start a worker process for your processing bucket. If you now send data to the system using your AETitle to address your bucket the processing should start (see the mb tool). A log-file /data/logs/bucket<AETitle>.log will contain the output of MagickBox when it tries to call your bucket. If your bucket produces some outputs they will be displayed as the processing.log.


Advanced: Persistent memory for buckets
=========================================

Buckets have a fixed environment, they receive input and output directories but otherwise the same files will be present during each run of the bucket. Files that are created inside the bucket - but not stored in /input and /output directories are deleted after the bucket stops. If your program requires space that is presistent between runs, like a database, use the /root/storage/memory directory inside the bucket. Place initial versions of your files into this directory. Once the bucket is installed and runs this directory is available inside the bucket as /memory/. Changes to files inside this directory will be available the next time the bucket is started.
