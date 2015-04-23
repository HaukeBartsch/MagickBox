<?php

  $DATA = "";
  if (isset($_GET['folder']))
    $DATA = $_GET['folder'];
  if ($DATA === "")
    return;
  $TYPE = "OUTPUT";
  if (isset($_GET['type']) && $_GET['type'] == "input")
    $TYPE = "INPUT";

  $fn = '/tmp/'.$DATA;
  //exec("cd /data/scratch/$DATA/OUTPUT; zip -r ".$fn." *");
  if ($TYPE == "OUTPUT") {
    exec("cd /data/scratch/; zip -r ".$fn." $DATA -i \"*/OUTPUT/*\"");
  } else {
    exec("cd /data/scratch/; zip -r ".$fn." $DATA -i \"*/INPUT/*\"");    
  }
  header("Content-Disposition: attachment; filename=".$DATA.".zip");
  header("Content-Type: application/zip");
  readfile( $fn );

  unlink($fn);
?>
