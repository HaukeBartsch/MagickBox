.. _Routing:

*******************************************
Routing DICOM files to other systems
*******************************************

The routing function sends processed DICOM files to other DICOM aware systems. It can react differently in response to success or failure of the computations. Here are some use cases:

    * specify the destination for sending result images
    * setup a dedicated system that collects copies of partially generated result images
    * try to send to a specific PACS system, if send fails try to send to an alternative system (see "break" option)

Routing is performed after a computation is finished. Computations are performed on an INPUT folder and results are placed in an OUTPUT folder. Routing only works on DICOM files found in the OUTPUT folder. 

At the level of the parent directory (directory that contains INPUT/ and OUTPUT/ folders) is one file initially called info.json. This file contains information that describes the input connection the data comes from. The computation should place a new file called 'proc.json' next to info.json. This file is evaluated to obtain the information required to start routing. Here is an example content::

    [{ "success": "failed", "message": "today is Monday" }]

This file specifies that the computation failed and provides a reason. In a later version of the program more than one success entry will be read. Currently only the first entry is evaluated.

Configuration
=============

The configuration of the routing function is done in the user interface. Here an example::

 { "routing": [
   {
 	"name": "Default Rule",
 	"AETitleIn": ".*",
   	"send": [
   		{
   			".*": {
   				"IP": "$me",
   				"PORT": "$port",
   				"AETitleSender": "ProcDefault",
   				"AETitleTo": "DCM4CHEE"
   			}
   		}
   	],
   	"break": 0
   },
   { 
     "name": "ProcRSI bucket routing of results",
     "AETitleIn": "ProcRSI",
     "AETitleFrom": "PACS",
     "send": [
         { "success": {
             "IP": "192.168.0.1",
             "PORT": "403",
             "AETitleSender": "me",
             "AETitleTo": "PACS",
             "break": 1,
	     "which": [
                { "0008:103e": ".*" }
             ]
       	   },
       	   "failed": {
             "IP": "192.168.0.1",
             "PORT": "403",
             "AETitleSender": "me",
             "AETitleTo": "PACS",
             "break": 1
           },
       	   "partial": {
             "IP": "192.168.0.1",
             "PORT": "403",
             "AETitleSender": "me",
             "AETitleTo": "PACS",
             "break": 1
           }
         }
     ],
     "break": 0
   }
  ]
 }

A DICOM connection from a station A (PACS) that sends DICOM data to station B (MagickBox) is specified by three types of information for both the sender and the receiver of the information. The Application Entity (AE) title of A and B, the internet protocol (IP) numbers of both stations and the port number that A called on the IP of B. MagickBox uses a single port for all its incoming connections, therefore routing depends on the AETitles and the status (success) returned by the computation.

The default rule above specifies "AETitleIn" which is the application entity title of our MagickBox (B). Additionally, or as an alternative one can also specify "AETitleFrom" as the AETitle that was used by the sending station (A). These two entries, AETitleIn and AETitleFrom are used by the routing function to find out if a specifc routing rule should be applied.

  Currently we do not support the IP-address as a possible filter. This is because the MagickBox runs as a virtual machine using NAT and port forwarding. Therefore the IP address of the incoming DICOM connection is not the IP of the sending machine but of the interface that forwards the packages (host computer running the VM).

For example, the default rule above applies if the AETitle called on B by A matches the pattern ".*". This is a regular expression that reads as some character (.) and there can be none, one or more of those. As this rules matches any string, the rule will always apply (default rule) regardless of where the data comes from. 

The "send" section contains one or more destinations for sending. Each of the entries is matched one at a time against the processing result (returned proc.json "success" value string). The default rule matches any value of "success" whereas the rule named "ProcRSI bucket routing of results" matches specific strings like "success", "failed", or "partial". If the "success" string matches one of these entries the corresponding destination is chosen to receive the OUTPUT data.

If the "break" entry of a successful sending operation has the value 1 sending stops without evaluating if other send entries would match as well. This allows for a fail-back send destination.

If a "which" statement is set DICOM files are tested before they are send. This filtering step allows you to select DICOM images based on DICOM tags. The value of each tag is filtered by a regular expression and only files that fullfil at least one of the "which" array entries are send to the corresponding destination.

Two placeholders are available "$me" references the IP of the MagickBox and "$port" the port specified in the Setup interface. Both usually refer to the DCM4CHEE virtual machine (VM) that can be installed side by side with the MagickBox VM.

Logging
=======

A log file for routing (/data/logs/routing.log) contains routing related messages.

