<?php

  // restart services

  if (isset($_GET['command']))
     $command = $_GET['command'];
  else
     return;
  if (isset($_GET['value']))
     $value = $_GET['value'];
  else
     return;

  $ok = exec('/usr/bin/sudo /data/code/bin/storescpd.sh stop', $ret);
  echo json_encode($ret);
?>
