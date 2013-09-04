<?php

  $DATA = "";
  if (isset($_GET['folder']))
    $DATA = $_GET['folder'];
  if ($DATA === "")
    return;

  $fn = '/tmp/'.$DATA.'.zip';
  exec("zip -r ".$fn." /data/scratch/$DATA/OUTPUT");
  header("Content-Disposition: attachment; filename=".$DATA.".zip");
  header("Content-Type: application/zip");
  readfile( $fn );

  unlink($fn);
?>
