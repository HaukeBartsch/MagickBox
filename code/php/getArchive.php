<?php

function addLog( $message ) {
  $ip = fopen("/data/logs/getArchive.log",'a');
  fwrite($ip, date(DATE_RFC2822)." ".$message . "\n");
  fclose($ip);
}

  $fileList = array();
  $path = '/data/scratch/archive';

  if (!file_exists($path)) {
     addLog("Error, archive does not exist, or could not be read...");
     echo ("{ \"message\": \"Error, archive does not exist on this machine\" }");
     return;
  }

  $files = glob($path."/*");

  // sort array of directories by file creation time
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
  $ar = array();
  foreach ($fileList as $archiveDir) { // these are now directories

       // take the first file in that directory (should be DICOM)
       $f = scandir($archiveDir);
       foreach ( $f as $file ) {
         if ( $file == "." || $file == ".." ) {
	    continue;
         }

         // read that files dicom information
         $ret = array();
         $lastLine = exec('/usr/bin/dcmdump +P "0010,0020" '.$archiveDir.'/'.$file, $ret);
	 $matches = array();
         $ok = preg_match("/.*\[([^\]]+).*/",$ret[0], $matches);
         if ( ! $ok ) {
            $patientid = "";
	    //print_r($matches);          
         } else {
            $patientid = $matches[1];
         }

         // read that files dicom information
         $ret = array();
         $lastLine = exec('/usr/bin/dcmdump +P "0010,0010" '.$archiveDir.'/'.$file, $ret);
	 $matches = array();
         $ok = preg_match("/.*\[([^\]]+).*/",$ret[0], $matches);
         if ( ! $ok ) {
            $patientname = "";
	    //print_r($matches);          
         } else {
            $patientname = $matches[1];
         }

         $ret = array();
         $lastLine = exec('/usr/bin/dcmdump +P "0008,0050" '.$archiveDir.'/'.$file, $ret);
	 $matches = array();
         $ok = preg_match("/.*\[([^\]]+).*/",$ret[0], $matches);
         if ( ! $ok ) {
            $accession = "";
	    //print_r($matches);          
         } else {
            $accession = $matches[1];
         }

         $ret = array();
         $lastLine = exec('/usr/bin/dcmdump +P "StudyDate" '.$archiveDir.'/'.$file, $ret);
	 $matches = array();
         $ok = preg_match("/.*\[([^\]]+).*/",$ret[0], $matches);
         if ( ! $ok ) {
            $studyDate = "";
	    //print_r($matches);          
         } else {
            $studyDate = $matches[1];
         }

         $siuid = basename($archiveDir);
         $ar[] = array( "PatientID" => $patientid, "AccessionNumber" => $accession, 
	                "SIUID" => $siuid, "StudyDate" => $studyDate, "PatientName" => $patientname );
         break; // only look at the first file
       }
  }

  echo json_encode($ar, JSON_PRETTY_PRINT);

?>
