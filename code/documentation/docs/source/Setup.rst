.. _Setup:

******************
Setup of MagickBox
******************

The setup of a MagickBox has to be performed if the IP of the machine that hosts the service changes. In this case the user interface provides a "Setup" button at the top that allows the user to specify the IP address of the hosts machine.

In order to setup a new MagickBox follow the steps outlined below.

   * install VirtualBox and the VirtualBox extension package (or another virtualization environment)
   * import the MasterTemplate OVA file
   * setup the virtual machines to start when the host computer starts (/Library/LaunchDaemon/ scripts)



Setup of MagickBox without VM
=============================

MagickBox can also run natively on a Linux system. This requires the following packages to be installed.

   * monit - provides monitoring of system services, starts and restarts services
   * gearman - provides job scheduling capabilities
   * dcmtk - provides native DICOM connectivity
   * apache/php5 - web-interface components and endpoints for mb-API calls
   * python2.7/pydicom - optional if processSingleFiles.py is used to create alternative views for the data

DICOM connectivity
==================

MagickBox uses dcmtk (OFFIS toolkit) for its basic DICOM Send/Receive functionality. In order to debug the connection to an existing node edit the /data/code/bin/logger.cfg file. Switch on logging by changing the line::

  log4cplus.rootLogger = DEBUG, console, logfile

This option will write DEBUG, INFO, WARN, ERROR, and FATAL messages to the storescp.log files in /data/logs/. Change the option back to::

  log4cplus.rootLogger = WARN, console, logfile

to reduce the number of log messages. Less log messages can improve the speed of the system.
