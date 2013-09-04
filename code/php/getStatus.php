<?php

  // /usr/bin/gearadmin
  // return status values
  $ok = exec('/usr/bin/gearadmin --status', $ret);
  $vals = $ret;
  foreach ($vals as &$value) {
    $ss = split("\t", $value);
    $value = $ss;
  }   
  echo json_encode($vals);
?>
