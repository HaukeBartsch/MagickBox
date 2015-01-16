<?php
  // make sure to make the upload size for files in php.ini large enough for this to work
  // data/scratch needs to be writable to www-data as well
  // we need to use the processing user, make www-data sudo su processing

  date_default_timezone_set('America/Los_Angeles');

  function addLog( $message ) {
    $ip = fopen("/data/logs/processZip.log",'a');
    fwrite($ip, date(DATE_RFC2822) . ": " . $message . "\n");
    fclose($ip);
  }

  $aetitle = "";
  if (isset($_POST['aetitle'])) {
    $aetitle = $_POST['aetitle'];
  }
  if ($aetitle === "") {
    addLog("Error: no AETitle found (break here)\n");
    return;
  }
  $filename = "";
  if (isset($_POST['filename'])) {
    $filename = $_POST['filename'];
  } else {
    addLog(" no filename in post\n");
    return;
  }
  $sender = "mb-shell";
  if (isset($_POST['sender'])) {
    $sender = $_POST['sender'];
  }

  $jobname = "";
  if (isset($_POST['jobname'])) {
    $jobname = $_POST['jobname'];
  }

  if (isset($_FILES)) {
    addLog(" found theFile in _FILES\n");
  } else {
    addLog(" no theFile in _FILES\n");
  }

  $ip = "unknown";
  if (isset($_SERVER['REMOTE_ADDR'])) {
     $ip = $_SERVER['REMOTE_ADDR'];
  } else {
     addLog("no REMOTE_ADDR");
  }

  function tempdir($dir, $prefix='', $mode=0700)
  {
    if (substr($dir, -1) != '/') $dir .= '/';

    do
    {
      $path = $dir.$prefix.mt_rand(0, 9999999);
    } while (!mkdir($path, $mode));

    return $path;
  }

  function chmod_r($path) {
    $dir = new DirectoryIterator($path);
    foreach ($dir as $item) {
        chmod($item->getPathname(), 0777);
        if ($item->isDir() && !$item->isDot()) {
            chmod_r($item->getPathname());
        }
    }
  }

  if ($_FILES["theFile"]["error"] > 0) {
    addLog("error in sending files");
  } else {
    $dir = tempdir("/data/scratch/", 'tmp.mb.'.$jobname.'_', 0777);
    chmod($dir, 0777);
    addLog("plan to start processing in " . $dir . " (copy zip file " . $filename ." there)");
    $fname = $dir . "/" . $filename;

    move_uploaded_file($_FILES["theFile"]["tmp_name"], $fname);
    $zip = new ZipArchive();
    if ($zip->open($fname) === TRUE) {
        addLog(" try to unzip " . $fname . " to " . $dir);
        $zip->extractTo($dir);
        $zip->close();
	addLog(" remove " . $dir . "/" . $filename . " after unzip");
        unlink($dir . "/" . $filename);
        chmod_r($dir);

	// we have to store an info.json file in this directory because otherwise scrubStorage will remove it as an orphan
        file_put_contents($dir . "/info.json", "{ \"CallerIP\": \"$ip\", \"AETitleCalled\": \"$aetitle\", \"AETitleCaller\": \"". $sender ."\", \"received\": \"". date(DATE_RFC2822). "\" }");
        addLog(" start processing by sending to bucket01: [ \"$sender\", \"$aetitle\", \"$ip\", \"$dir\" ]");
        shell_exec('nohup sudo -u processing -S /data/streams/bucket01/process.sh \"'.$sender.'\" \"'.$aetitle.'\" '.$ip.' \"'.$dir.'\" > /dev/null 2>/dev/null &');
    } else {
        addLog(" could not open zip file " . $_FILES["theFile"]["tmp_name"]);
    }
  }
  addLog(" done");        

?>
