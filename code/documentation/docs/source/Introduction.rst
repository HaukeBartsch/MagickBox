.. _Introduction:

********************
System Architecture
********************

The system runs inside a virtual machine usually called MasterTemplate. There can be a secondary virtual machine with a mini-PACS such as DICOM4CHEE (http://www.dcm4che.org). This secondary system is used as an image storage location only.

Functionality provided by MasterTemplate:

	* DICOM node listening to incoming connections
	* Web interface which provides a user interface for configuration, log files and processed data downloads. The routing functionality can send processed data back. In this mode no continuous access to the web interface is required appart from the initial configuration.

MasterTemplate runs on a Host computer using network address translation (NAT). Using this configuration no separate IP address is required. In order to be accessible to the outside the virtual machine forwards two ports to the outside world.

	[TCP, Host IP, port 11113] -> [TCP, Guest IP, port 1234]
	[TCP, Host IP, port 2813]  -> [TCP, Guest IP, port 2813]
	[TCP, Host IP, port 4321]  -> [TCP, Guest IP, port 22] (optional ssh access)

The web interface is available at:

	http://<Host IP>:2813/

Images can be send to port 11113 using a tool such as OsiriX or storescp (dcmtk toolkit). 
