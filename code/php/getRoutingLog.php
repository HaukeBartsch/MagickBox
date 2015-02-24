<?php
  $routing_file = '/data/logs/routing.log';

  $content = file_get_contents($routing_file);
  $content = explode("\n", $content);
  $content = array_reverse($content);
  $erg = array();
  foreach($content as $line) {
     // check by regexp
     $dat = preg_split('/,/', $line)[0];
     $ar = preg_split('/CALLED routing with/', $line);
     if (count($ar) > 1) {
       $erg[] = $dat.$ar[1];
     }
     $ar = preg_split('/ROUTE:/', $line);
     if (count($ar) > 1) {
       $ar = preg_split('/--/', $ar[1]);
       $erg[] = $dat.$ar[1];
     }
  }
  echo (json_encode($erg));
  return;
?>