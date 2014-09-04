.. _Shell:

************************
MagickBox command shell
************************

The MagickBox command shell is used to query, send, receive, and remove jobs from a MagickBox. This command line tool provides a convenient way to interface with MagickBox instances for larger projects. If you have ever worked with programs like git the usage should be familiar. 

You can download the command shell executable (mb) for your platform here:

* Linux (MD5 = d0bc07803e49a62a0265f8151db2efa6)
	wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/LinuxAMD64/mb

* MacOSX (MD5 = 309cce38fbb9159a8f965e763e33f13a)
	wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/MacOSX/mb

* Windows (MD5 = ac417a3786a5c260009325797267c20c)
	wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/Windows/mb.exe

This is the basic help page of the application (after calling ./mb)::

	NAME:
	   mb - MagickBox command shell for query, send, retrieve, and delete of data.
	
	   Start by listing known MagickBox instances (queryMachines). Identify your machine
	   and use selectMachine to specify it for all future commands. Also add your own
	   identity using the sender command. These steps need to be done only once.
	
	   Most calls return textual output in JSON format that can be processed by tools
	   such as jq (http://stedolan.github.io/jq/).
	
	   Regular expressions are used to identify individual sessions. They are applied
	   to all field values returned by the list command. If a session matches, the
	   command will be applied to it (list, push, pull, remove).
	
	USAGE:
	   mb [global options] command [command options] [arguments...]
	
	VERSION:
	   0.0.1
	
	AUTHOR:
	  Hauke Bartsch - <HaukeBartsch@gmail.com>
	
	COMMANDS:
	   pull, g		Retrieve matching jobs [pull <regular expression>]
	   push, p		Send a directory for processing [push <aetitle> <dicom directory>]
	   remove, r		Remove data [remove <regular expression>]
	   list, l 		Show list of matching jobs [list [regular expression]]
	   log, l		Show processing log of matching jobs [log [regular expression]]
	   queryMachines, q	Display list of known MagickBox instances [queryMachines]
	   selectMachine, s	Specify the default MagickBox [selectMachine [<IP> <port>]]
	   sender, w	  	Specify a string identifying the sender [sender [<sender>]]
	   help, h 		Shows a list of commands or help for one command
	   
	GLOBAL OPTIONS:
	   --help, -h		show help
	   --version, -v	print the version
	
=======
Setup
=======

Start by using the queryMachines command to identify your MagickBox (needs to be installed first). You need to set your MagickBox using 'selectMachine' once and all future calls to mb will use that machine. Also specify the 'sender' (your name or the name of your project for example) as it makes it easier later to identify your scans::

	> mb queryMachines
	[{ "id": "0", "machine": "137.110.172.9", "port": "2813" },
	 { "id": "1", "machine": "10.193.13.181", "port": "2813" }]
	> mb selectMachine 137.110.172.9 2813
	> mb sender hauke:project01

========
Usage
========

The basic workflow is to first identify some data that is locally available on your harddrive. This could be a directory with T1-weighted images in DICOM format. Send the data to a processing bucket on your MagickBox. Here an example that sends data for gradient unwarp (distortion correction for MRI data)::

	> mb push ProcGradUnwarp ~/data/testdata/DICOMS

Mb will zip all files in the directory and upload the zip-file to your MagickBox for processing using the 'ProcGradUnwarp' bucket. Check on the progress of the processing using the 'list' and 'log' commands::

	> mb list hauke
	[{
	  "AETitleCalled": "ProcGradUnwarp",
	  "AETitleCaller": "hauke:project01",
	  "CallerIP": "10.0.2.2",
	  "lastChangedTime": "Tue, 02 Sep 2014 00:05:57 -0700",
	  "pid": "tmp.8938590",
	  "processingLast": 115683,
	  "processingLogSize": 1459,
	  "processingTime": 387,
	  "received": "Mon Sep  1 23:59:30 PDT 2014",
	  "scratchdir": "tmp.cPQ1qwWqdw"
	}]

The 'list' command on its own will list all sessions that exist on the MagickBox, specifying the sender or parts of the sender string will limit the output to entries that match. Here we have a single session returned in JSON format. As a unique key to identify this session use the value of the 'scratchdir' key which is based on a random sequence of letters and numbers.

Use any other string as a search term instead of the sender. You could specify "Sep" and all session that contain "Sep" will be listed.

A command that works very similar to 'list' is 'log'. Additionally to the information listed by 'list', 'log' will also contain the processing log. Getting the processing log is more time consuming, therefore 'log' is a separate command. You can use it for example to search for error messages in the log files.

Once you have identified your session and processing finished you can download them using 'pull' with the same search term::

	> mb pull hauke

The output of your processing will be downloaded as a zip file into your current directory. The name of the zip file will contain the 'scratchdir'.
