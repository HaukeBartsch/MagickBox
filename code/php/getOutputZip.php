<?php

  $DATA = "";
  if (isset($_GET['folder']))
    $DATA = $_GET['folder'];
  if ($DATA === "")
    return;

  $fn = '/tmp/'.$DATA.'.zip';
  exec("cd /data/scratch/$DATA/OUTPUT; zip -r ".$fn." *");
  header("Content-Disposition: attachment; filename=".$DATA.".zip");
  header("Content-Type: application/zip");
  readfile( $fn );

  unlink($fn);
?>
