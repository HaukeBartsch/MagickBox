<?php
//
// call with ?siuid=Series Instance UID to get the values for a single subject
//

function addLog( $message ) {
  $ip = fopen("/data/logs/getArchive.log",'a');
  fwrite($ip, date(DATE_RFC2822)." ".$message . "\n");
  fclose($ip);
}

  // This could be something in archive - or in scratch (if it comes from mb)
  $siuid = "";
  if (isset($_GET['siuid'])) {
     $siuid = $_GET['siuid'];
  }

  $fileList = array();
  $path = '/data/scratch/archive';

  if (!file_exists($path)) {
     addLog("Error, archive does not exist, or could not be read...");
     echo ("{ \"message\": \"Error, archive does not exist on this machine\" }");
     return;
  }

  if ($siuid == "") {
    $files = glob($path."/*");
  } else {
    // a single entry instead of a whole directory
    $files = [];
    $files[] = $path.'/'.$siuid;
    if (!file_exists($files[0])) { // in this case the siuid could refer to a directory in scratch itself (load its info and return)
       if (file_exists('/data/scratch/'.$siuid.'/info.json')) {
           $cont = json_decode(file_get_contents('/data/scratch/'.$siuid.'/info.json'), True);
	   $ar = [];
	   $ar[] = $cont;
           echo json_encode($ar);
	   return;
       }
    }
  }

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
