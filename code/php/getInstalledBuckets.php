<?php

  $dirs = glob('/data/streams/*');
  foreach ($dirs as &$value) {
     $v = end(split("/", $value));
     $value = $v;
  }
  $vals = $dirs;

  echo json_encode( $vals );
?>