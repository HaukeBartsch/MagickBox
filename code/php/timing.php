<?php

$db_file = "/data/code/php/timings.json";

function addLog( $message ) {
  $ip = fopen("/data/logs/timing.log",'a');
  fwrite($ip, $message . "\n");
  fclose($ip);
}

function loadDB() {
   global $db_file;
   $d = NULL;

   // parse permissions
   if (!file_exists($db_file)) {
      addLog ('error: permission file does not exist');
      return $d;
   }
   if (!is_readable($db_file)) {
      addLog ('error: cannot read file...');
      return $d;
   }
   $d = json_decode(file_get_contents($db_file), true);
   if ($d == NULL) {
      addLog('error: could not parse the time database file');
   }
   return $d;
}

function saveDB( $d ) {
   global $db_file;

   if (!file_exists($db_file)) {
      addLog('error: timing file does not exist');
      //return;
   }
   if (!is_writable($db_file)) {
      addLog('Error: cannot write database timing file ('.$db_file.')');
      //return;
   }
   // be more careful here, we need to write first to a new file, make sure that this
   // works and copy the result over to the pw_file
   $testfn = $db_file . '_test';
   addLog("try to write to " . $testfn);
   file_put_contents($testfn, json_encode($d, JSON_PRETTY_PRINT));
   if (filesize($testfn) > 0) {
      // seems to have worked, now rename this file to pw_file
      rename($testfn, $db_file);
   } else {
      syslog(LOG_EMERG, 'ERROR: could not write file into '.$testfn);
   }
}

//
// read input
//

if (isset($_GET['aetitle'])) {
  $aetitle = $_GET['aetitle'];
  $aetitle = trim($aetitle, "\\\"");
} else {
  addLog("no aetitle argument given");
  return; 
}


//
// Compute running average and variance
//

if (isset($_GET['time'])) {
  $time = $_GET['time'];
  addLog("got some time :" . $time);
  $d = loadDB();
  if ($d == NULL) {
     $d = array();
     $d[] = array("aetitle" => $aetitle, "avg" => $time, "var" => 0, "n" => 1);
  } else {
     $found = False;
     foreach( $d as $key => &$value) {
       if ($value["aetitle"] == $aetitle) {
          $found = True;

	  $value["avg"] = $value["avg"] + ($time - $value["avg"])/$value["n"];
	  $value["var"] = $value["var"] + ($time - $value["avg"])*($time - $value["avg"]);
          $value["n"] = $value["n"] + 1;
          addLog("update entry for ". $aetitle . " to mean time [in seconds]: " . $value["avg"] . " (var: " . sqrt($value["var"]/($value["n"]-1)) . ")");
          break;
       }
     }
     if ($found == False) {
        $d[] = array("aetitle" => $aetitle, "avg" => $time, "std" => 0, "n" => 1);
        addLog("add first time entry for ". $aetitle . " to mean time [in seconds]" . $value["avg"] . " (var: " . $value["var"] . ")");
     }
  }
  saveDB($d);
} else { // return the time estimate for this aetitle
  $d = loadDB();
  if ($d == NULL) {
    echo("[]");
  } else {
    $found = False;
    foreach( $d as $key => $value) {
      if ($value["aetitle"] == $aetitle) {
         $found = True;
         if ($value["n"] > 2) {
           $ret = array("aetitle" => $aetitle, "avg" => round($value["avg"]), "std" => round(sqrt( $value["var"]/($value["n"]-1)), 2));
         } else {
           $ret = array("aetitle" => $aetitle, "avg" => $value["avg"], "std" => "0");
         }
         echo(json_encode($ret));
         break;
      }
    }
    if ($found == False) {
      echo("[]");
      addLog("queried for ". $aetitle. " but did not find this bucket in timing table");
    }
  }
}

?>