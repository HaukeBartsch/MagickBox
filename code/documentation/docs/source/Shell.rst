.. _Shell:

************************
MagickBox command shell
************************

The MagickBox command shell is used to query, send, receive, and remove jobs from a collection of MagickBox machines. This command line tool provides a convenient way to interface with MagickBox instances for larger projects. If you have ever worked with programs like git the usage pattern should be familiar. 

You can download the command shell executable (mb) for your platform here:

* Linux (MD5 = 764a386128376368528cdd6e66f15487)
  wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/LinuxAMD64/mb

* MacOSX (MD5 = 916df7853de9d82f6ec7a3b20a3d0c9e)
  wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/MacOSX/mb

* Windows (MD5 = 68b9e25fef9f351eca91be531e2f033d)
  wget https://github.com/HaukeBartsch/MagickBox/raw/master/code/mb-shell/Windows/mb.exe


This is the basic help page of the application::

	NAME:
	   mb - MagickBox command shell for query, send, retrieve, and deletion of data.
	
	   Setup: Start by listing known MagickBox instances (queryMachines). Identify
	     your machine and add them using 'activeMachines add'. They will be used
		 for all future commands.
	
	     Add your own identity using the setSender command. You can also add your 
		 projects name (see example below) to make it easier to identify your 
		 session later.
	
	   Most calls return textual output in JSON format that can be processed by 
	   tools such as jq (http://stedolan.github.io/jq/).
	
	   Regular expressions are used to identify individual sessions. They can 
	   be supplied as an additional argument to commands like list, log, push, 
	   pull, and remove. Only if a session matches, the command will be applied.
	
	   If data is send (push) and there is more than 1 machine available that 
	   provide that type of processing one of them will be selected based on load. 
	   Commands such as 'list' will return the machine and port used for that session.
	
	   Example:
	     > mb setSender "hauke:testproject"
	     > mb push Proc data_01/
	     > mb push Proc data_02/
	     > mb list hauke:testproject
	     > mb pull hauke:testproject
	
	
	USAGE:
	   mb [global options] command [command options] [arguments...]
	
	VERSION:
	   0.0.5
	
	AUTHOR:
	  Hauke Bartsch - <HaukeBartsch@gmail.com>
	
	COMMANDS:
	   pull, g		Retrieve matching jobs output [pull <regular expression>]
	   pull-input, pi	Retrieve matching jobs input [pull-input <regular expression>]
	   push, p     		Send a directory for processing [push <aetitle> 
	   					<dicom directory> [<arguments>]]
	   remove, r		     Remove data [remove <regular expression>]
	   list, l 		     Show list of matching jobs [list [regular expression]]
	   log, l		     	  Show processing log of matching jobs 
	   						  [log [regular expression]]
	   queryMachines, q		  Display list of known MagickBox instances 
                                          [queryMachines]
	   setSender, w	  		  Specify a string identifying the sender 
	   						  [setSender [<sender>]]
	   setSetting 			  Get or overwrite a program setting [setSetting 
	   					      [<name> | <name> <value>]]
	   computeModules, c		  Get list of buckets for the active machines
	   activeMachines, a		  Get list of active magick box machines
	   help, h	   		  Shows a list of commands or help for one command
	   
	GLOBAL OPTIONS:
	   --config-sender	Identify yourself, value is used as AETitleCaller 
	   			        [--config-sender <string>]
	   --help, -h			 show help
	   --version, -v		 print the version
	

=======
Setup
=======

Start by using the queryMachines command to identify your processing machines (MagickBox needs to run on those machines). You need to activate your MagickBox instances using 'activeMachines' once and all future calls to mb will use these machines. Also specify the 'sender' (your name or the name of your project for example) as it makes it easier later to identify your scans::

	> mb queryMachines
	[{ "id": "0", "machine": "137.110.172.9", "port": "2813" },
	 { "id": "1", "machine": "10.193.13.181", "port": "2813" }]
	> mb activeMachines add 137.110.172.9 2813
	> mb activeMachines add 10.193.172.181 2813
	> mb setSender hauke:project01

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

Use any other string as a search term instead of the sender. You could specify "Sep" and all session that contain "Sep" will be listed. The specified string can also be a regular expression.

A command that works very similar to 'list' is 'log'. Additionally to the information listed by 'list', 'log' will also contain the processing log. Getting the processing log is more time consuming, therefore 'log' is a separate command. You can use it for example to search for error messages in the log files.

Once you have identified your session and processing finished you can download them using 'pull' with the same search term::

	> mb pull hauke

The output of your processing will be downloaded as a zip file into your current directory. The name of the zip file will contain the 'scratchdir'.
