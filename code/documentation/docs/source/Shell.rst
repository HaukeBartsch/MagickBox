.. _Shell:

************************
MagickBox command shell
************************

The MagickBox command shell is used to query, send, receive, and remove jobs from a MagickBox. This command line tool provides a convenient way to interface with MagickBox instances for larger projects.

You can download the command shell executable (mb) for your platform here:

* Linux (MD5 = d0bc07803e49a62a0265f8151db2efa6)
	wget https://github.com/HaukeBartsch/MagickBox/tree/master/code/mb-shell/LinuxAMD64/mb

* MacOSX (MD5 = 309cce38fbb9159a8f965e763e33f13a)
	wget https://github.com/HaukeBartsch/MagickBox/tree/master/code/mb-shell/MacOSX/mb

* Windows (MD5 = ac417a3786a5c260009325797267c20c)
	wget https://github.com/HaukeBartsch/MagickBox/tree/master/code/mb-shell/Windows/mb.exe

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

Start by using the queryMachines command to identify your MagickBox (needs to be installed first). You need to set your MagickBox using 'selectMachine' once and all future calls to mb will use that machine. Also specify the 'sender' (your name for example) as it makes it easier later to identify your scans::

	> mb queryMachines
	[{ "id": "0", "machine": "137.110.172.9", "port": "2813" },
	 { "id": "1", "machine": "10.193.13.181", "port": "2813" }]
	> mb selectMachine 137.110.172.9 2813
	> mb sender hauke
