<?php

  $fileList = array();
  $files = glob('/data/scratch/*/info.json');
  foreach ($files as $file) {
      $fileList[filemtime($file)] = $file;
  }
  ksort($fileList);
  $fileList = array_reverse($fileList, TRUE);
  //print_r $fileList;
  $ar = array();
  foreach ($fileList as $fn) {
       $c = file_get_contents($fn);
       if ( $c == FALSE )
          continue;
       $cont = json_decode($c, TRUE);
       // check if we have a valid processing folder here
       if (!array_key_exists('CallerIP', $cont))
          continue;

       // printf("try to read in %s %s\n", $fn, $c);
       $ar[] = $cont;

       $parts = explode("/",$fn);
       $ar[count($ar)-1]['scratchdir'] = $parts[count($parts)-2];
       // add the first directory in side INPUT
       $inputs = glob('/data/scratch/'.$ar[count($ar)-1]['scratchdir'].'/INPUT/*', GLOB_ONLYDIR);
       $parts2 = explode("/",$inputs[0]);
       $ar[count($ar)-1]['pid'] = $parts2[count($parts2)-1];
  }

  echo json_encode($ar);

?>
