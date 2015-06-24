<?php

  $fileList = array();
  $files = glob('/data/scratch/*/info.json');

  // sort array of files by file creation time
  function cmp($a, $b) {
    $x = filemtime($a);
    $y = filemtime($b);
    if ($x == $y) {
       return 0;
    }
    return ($x < $y) ? -1 : 1;
  }
  usort($files, "cmp");

  $fileList = array_reverse($files, TRUE);
  //print_r $fileList;
  $ar = array();
  foreach ($fileList as $fn) {
       $c = file_get_contents($fn);
       if ( $c == FALSE ) {
          //echo ("could not read info.json ". $fn);
          continue;
       }
       $cont = json_decode($c, TRUE);
       // check if we have a valid processing folder here
       if (!array_key_exists('CallerIP', $cont)) {
          //echo ("could not find CallerIP in " . $c);
          continue;
       }

       // printf("try to read in %s %s\n", $fn, $c);
       $ar[] = $cont;

       $parts = explode("/",$fn);
       //echo (" the array key is: " . count($ar)-1);
       $ar[count($ar)-1]['scratchdir'] = $parts[count($parts)-2];
       // add the directory that INPUT links to
       $ar[count($ar)-1]['pid'] = basename(realpath('/data/scratch/'.$ar[count($ar)-1]['scratchdir'].'/INPUT'));

       $fname = '/data/scratch/'.$ar[count($ar)-1]['scratchdir'].'/processing.log';
       if ( ! is_readable($fname) ) {
          $ar[count($ar)-1]['lastChangedTime'] = '0';
          continue;
       }
       $fileinfo = stat($fname);
       $ar[count($ar)-1]['lastChangedTime'] = date(DATE_RFC2822, $fileinfo['mtime']);
       $ar[count($ar)-1]['processingTime'] = -(filemtime($fn)-$fileinfo['mtime']);
       $ar[count($ar)-1]['processingLogSize'] = $fileinfo['size'];
       $ar[count($ar)-1]['processingLast'] = time() - $fileinfo['mtime'];

       # we can add now processing results to the output 
       # we expect them to be in /data/db/<AETitleCaller>/<scratchdir>/<somestring>.json
       if (array_key_exists('AETitleCaller', $cont)) {
           $measfn = '/data/db/'.$cont['AETitleCaller'].'/'.$ar[count($ar)-1]['scratchdir'].'/';
           $files = glob($measfn.'*.json');
           foreach ($files as $file) {
	      # check if this is a directory
              if ( is_readable($file) ) {
                 $c = file_get_contents($file);
                 if ( $c == FALSE ) {
                    continue;
                 }
                 $dat = json_decode($c, TRUE);
                 if (array_key_exists('measures', $ar[count($ar)-1])) {
                   $ar[count($ar)-1]['measures'][basename($file,'.json')] = $dat;
                 } else {
   	           $ar[count($ar)-1]['measures'] = array(basename($file,'.json') => $dat);
                 }
              }
           }
       }
  }

  echo json_encode($ar);

?>
