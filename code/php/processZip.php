<?php
  // make sure to make the upload size for files in php.ini large enough for this to work
  // data/scratch needs to be writable to www-data as well
  // we need to use the processing user, make www-data sudo su processing

  function addLog( $message ) {
    $ip = fopen("/data/logs/processZip.log",'a');
    fwrite($ip, $message . "\n");
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
    $dir = tempdir("/tmp/", "tmp.", 0777);
    chmod($dir, 0777);
    addLog("plan to start processing in " . $dir);
    $fname = $dir . "/" . $_POST["filename"];

    move_uploaded_file($_FILES["theFile"]["tmp_name"], $fname);
    $zip = new ZipArchive();
    if ($zip->open($fname) === TRUE) {
        addLog(" try to unzip files to " . $dir);
        $zip->extractTo($dir);
        $zip->close();
        unlink($dir . "/" . $_POST["filename"]);
        chmod_r($dir);

        //file_put_contents($dir . "/info.json", "{ \"ip\": \"$ip\", \"AETitleCalled\": \"$aetitle\" }");
        addLog(" start processing by sending to bucket01");        
        shell_exec('nohup sudo -u processing -S /data/streams/bucket01/process.sh \"mb-shell\" \"'.$aetitle.'\" '.$ip.' \"'.$dir.'\" > /dev/null 2>/dev/null &');
    } else {
        addLog(" could not open zip file " . $_FILES["theFile"]["tmp_name"]);
    }
  }

?>
