<?php

  date_default_timezone_set('America/Los_Angeles');

  function addLog( $message ) {
    $ip = fopen("/data/logs/restartServices.log",'a');
    fwrite($ip, date(DATE_RFC2822) . ": " . $message . "\n");
    fclose($ip);
  }

  // restart services

  if (isset($_GET['command']))
     $command = $_GET['command'];
  else
     return;
  if (isset($_GET['value']))
     $value = $_GET['value'];
  else
     return;


  addLog("stop service");
  shell_exec('/usr/bin/sudo -u processing -S /data/code/bin/storescpd.sh stop > /dev/null 2>/dev/null &');
  addLog("start service");
  shell_exec('/usr/bin/sudo -u processing -S /data/code/bin/storescpd.sh start > /dev/null 2>/dev/null &');
  addLog("restart done");
?>
