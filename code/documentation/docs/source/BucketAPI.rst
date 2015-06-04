.. _BucketAPI:

**************
How to add processing capabilities 
**************

Processing functionality is added as docker containers that contain a basic structure of files. Such a container can be created using the following call::

 wget https://github.com/HaukeBartsch/MagickBox/blob/master/code/bin/buckets
 chmod gou+rx buckets
 ./buckets create mytestbucket

This will create a docker image with two special files. The first describes the docker container. Edit the file using::

 docker run -i -t mytestbucket /bin/bash
 vi /root/storage/info.json

Use a second terminal to commit your changes after you edited the file::

 docker commit <running image id> -m "changed something"

Now is a good time to install some programs into the bucket. The programs will receive input data in one directory and output data in another directory - everything else will be done by magic. The MB docker container is currently based on ubuntu so you can install tools using apt-get::

 docker run -i -t mytestbucket /bin/bash
 apt-get update

Follow the install instructions for Linux and you should be able to add your software to the bucket. Don't forget to commit the changes from the second terminal.

In a second file add the processing instructions that call your program::

 docker run -i -t mytestbucket /bin/bash
 vi /root/work.sh

Currently the mb program can be used to send arbitrary data to a MagickBox installation. But times the data is send as a DICOM stream using a PACS, OsiriX or dcmtk tools.
