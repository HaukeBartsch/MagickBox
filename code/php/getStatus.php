<?php

  // /usr/bin/gearadmin
  // return status values
  $ok = exec('/usr/local/bin/gearadmin --status', $ret);
  $vals = $ret;
  $erg = array();
  foreach ($vals as &$value) {
    $ss = split("\t", $value);
    if (count($ss) > 2)
      $erg[] = $ss;
  }   
  // todo: add timing information as well for all buckets

  echo json_encode($erg);
?>
