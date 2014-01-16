.. _Setup:

******************
Setup of MagickBox
******************

The setup of a MagickBox has to be performed if the IP of the machine that hosts the service changes. In this case the user interface provides a "Setup" button at the top that allows the user to specify the IP address of the hosts machine.

In order to setup a new MagickBox follow the steps outlined below.

(todo)

DICOM connectivity
==================

MagickBox uses dcmtk (OFFIS toolkit) for its basic DICOM Send/Receive functionality. In order to debug the connection to an existing node edit the /data/code/bin/logger.cfg file. Switch on logging by changing the line::

  log4cplus.rootLogger = DEBUG, console, logfile

This option will write DEBUG, INFO, WARN, ERROR, and FATAL messages to the storescp.log files in /data/logs/. Change the option back to::

  log4cplus.rootLogger = WARN, console, logfile

To reduce the number of log messages to the log file. This should improve the speed slightly as well.
