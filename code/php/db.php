<?php
#
# Database frontend for storing quantitative results (instead of files). This
# system uses plugins for data types.
#
# Data is stored as:
#    /data/db/<sender>/<key>/<value tupel.csv>
#
# Test for looking for data in directory:
#    curl -G -d 'sender=me&parse=/data/scratch/tmp.ABCD' http://localhost:2813/code/php/db.php
#

function addLog( $message ) {
  $ip = fopen("/data/logs/db.log",'a');
  fwrite($ip, date(DATE_RFC2822) . ": " . $message . "\n");
  fclose($ip);
}
addLog("called");

#
# we want to be able to store data as well, but we have a store for data already ....
#
# What we really want is to query the data we have, if we had a job that 
# parses the files on our disk we could specify extraction methods that
# can automatically pull out information like Left.txt and Right.txt, MI.txt for NQ.
# this should be a low nice job in the background that looks for new files in scratch
# and has a list of plugin parsers to extract information as key/value pairs
#

# Install incron to be able to react to changes on /data/scratch/
# Problem with incron is that it cannot watch files in subdirectories... better to call 
# db.php manually after each bucket performed.
# sudo apt-get install incron
# add processing user to /etc/incron.allow
# create entry using incrontab -e (user processing)
#   /data/scratch/ IN_MODIFY 

$sender = "";
if (isset($_GET['sender'])) {
  $sender = $_GET['sender'];
} else {
  echo("Error: sender is required");
  addLog("Error: sender is required");
}

$plugindir='/data/code/php/db-plugins';

function endsWith( $haystack, $needle) {
  return $needle === "" || (($temp = strlen($haystack) - strlen($needle)) >= 0 && strpos($haystack, $needle, $temp) !== FALSE);
}

# requires "f" saves results to "result"
function call_plugins ( $f ) {
  global $plugindir;

  $result=array();
  $plugins=scandir( $plugindir );
  foreach ($plugins as $plugin) {
     if ($plugin == "." || $plugin == "..")
        continue;
     if ( is_file( $plugindir."/".$plugin ) 
         && is_executable( $plugindir."/".$plugin ) 
         && endsWith($plugin,".code")) {
       $out=array();
       exec($plugindir."/".$plugin." ".$f, $out);
       if (count($out) > 0) {
         $result[] = json_decode($out[0], True);
       }
     }
  }
  return $result;
}

function store_result ( $sender, $key, $file, $result ) {
   # store whatever is in result with the information from sender
   $fn='/data/db/'.$sender.'/'.$key;
   mkdir($fn, true);
   file_put_contents($fn."/".$file, json_encode($result));
}

function getDirContent($dir, &$result = array()) {
  $files = scandir($dir);

  foreach($files as $key => $value) {
    $path = realpath($dir.DIRECTORY_SEPARATOR.$value);
    if (!is_dir($path)) {
      $result[] = $path;
    } else if (is_dir($path) && $value != "." && $value != "..") {
      getDirContent($path, $result);
      $result[] = $path;
    }
  }
}

#
# if a location is supplied try to parse it and add to database
#
if (isset($_GET['parse'])) {
   $parse = $_GET['parse'];
   $key=$parse;
   addLog("Called for ".$parse);
   # call all plugins for all files in this result directory
   if (is_file($parse)) {
      addLog('single file');
      $result = call_plugins( $parse );
      store_result( $sender, $key, $parse, $result );
   } else {
      $files = array();
      getDirContent( $parse, $files );
      addLog('Check '.count($files).' separate files in '.$parse);
      foreach($files as $file) {
        $result = call_plugins( $file );
        store_result( $sender, $key, $parse, $result );
      }
   }
} else {

}
addLog("Finished");

# if we get arguments return the level below
#



?>
