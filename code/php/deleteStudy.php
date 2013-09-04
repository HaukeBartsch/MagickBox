<?php

function deleteDirectory($dirPath) { 
    $printonce = FALSE;
    if (is_dir($dirPath)) { 
        $objects = scandir($dirPath); 
        foreach ($objects as $object) { 
          if ($object != "." && $object != "..") { 
            if (filetype($dirPath."/".$object) == "dir"){
                 deleteDirectory($dirPath."/".$object);
            }else{
                 $ok = unlink($dirPath."/".$object);
                 if ($ok == FALSE && $printonce == FALSE) {
                   echo "could not delete file ".$dirPath."/".$object." (permissions?) ";
		   $printonce = TRUE;
                 }
            } 
          }
          reset($objects); 
          rmdir($dirPath);
        } 
    }
}

  if (!isset($_GET['scratchdir'])) {
     echo "ERROR: no scratchdir input";
     return;
  }
  if ( $_GET['scratchdir'] == "" || $_GET['scratchdir'] == null ) {
     echo "ERROR: arg is empty";
     return;
  }
  $bla = "/data/scratch/".$_GET['scratchdir'];
  $study = realpath($bla);


  if ($study == FALSE)
     return; // path does not exist
  // check if the path is ok
  $blub = explode("/", $study);

syslog(LOG_EMERG, count($blub));

  if (count($blub) < 3)
     return; // is not in /data/scratch
  if ($blub[1] == "data" && $blub[2] == "scratch") {
     echo " will delete now $study";
     deleteDirectory( $study );
  } else {
     echo " will not delete anything";
  }
  
?>
