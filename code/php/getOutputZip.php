<?php

  $DATA = "";
  if (isset($_GET['folder']))
    $DATA = $_GET['folder'];
  if ($DATA === "")
    return;

  $fn = '/tmp/'.$DATA;
  //exec("cd /data/scratch/$DATA/OUTPUT; zip -r ".$fn." *");
  exec("cd /data/scratch/; zip -r ".$fn." $DATA -i \"*/OUTPUT/*\"");
  header("Content-Disposition: attachment; filename=".$DATA.".zip");
  header("Content-Type: application/zip");
  readfile( $fn );

  unlink($fn);
?>
