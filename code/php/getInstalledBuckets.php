<?php

  $dirs = glob('/data/streams/*');
  $ddirs = array();
  foreach ($dirs as &$value) {
     $info_fn = $value."/info.json";
     if (file_exists($info_fn) ) {
       $info = json_decode( file_get_contents( $value."/info.json" ), true);
       //$v = end(split("/", $value));
       $v = $info['name'];
       if(array_key_exists('enabled', $info) && $info['enabled'] == 1) {
         $ddirs[] = $info;       
       }
     }
  }
  $vals = $ddirs;

  echo json_encode( $vals );
?>