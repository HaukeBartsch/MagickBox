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
                   echo "\ncould not delete file ".$dirPath."/".$object." (permissions?)";
		   $printonce = TRUE;
                 }
            } 
          }
          reset($objects); 
          rmdir($dirPath);
        } 
    }
}

  // either we have a scratchdir as an argument
  if (isset($_GET['scratchdir']) && $_GET['scratchdir'] != "" && $_GET['scratchdir'] != null ) {
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
  } elseif (isset($_GET['SIUID']) && $_GET['SIUID'] != "" && $_GET['SIUID'] != null ) {
    $bla = "/data/scratch/archive/".$_GET['SIUID'];
    $study = realpath($bla);

    if ($study == FALSE)
       return; // path does not exist
    $blub = explode("/", $study);

    if (count($blub) < 4)
       return; // is not in /data/scratch/archive
    if ($blub[1] == "data" && $blub[2] == "scratch" && $blub[3] == "archive") {
       // echo " we will have to delete archive $study";
       // now we need to delete the tmp dir that points to this study as well (check if INPUT points it this directory)
       // first check all tmp.* if their INPUT points to study
       $dirs = glob('/data/scratch/tmp.*');
       foreach ($dirs as $dir) {
          if ( $dir == "." || $dir == ".." ) {
             continue;
          }  
          $rp = realpath($dir."/INPUT");
          if ($rp == $study) {
            echo ("will delete $dir now");
            deleteDirectory( $dir );
          }
       }
       syslog(LOG_EMERG, " we delete now: ".$study);
       echo ("will delete $study now");
       deleteDirectory( $study );
    } else {
       echo ("will not delete anything");
    }   
  }
?>
