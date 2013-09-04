<?php

  $dirs = glob('/data/streams/*');
  $ddirs = [];
  foreach ($dirs as &$value) {
     $info_fn = $value."/info.json";
     if (file_exists($info_fn) ) {
       $info = json_decode( file_get_contents( $value."/info.json" ), true);
       //$v = end(split("/", $value));
       $v = $info['name'];
       
       $ddirs[] = $info;
     }
  }
  $vals = $ddirs;

  echo json_encode( $vals );
?>