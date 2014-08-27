<?php
  // make sure to make the upload size for files in php.ini large enough for this to work
  // data/scratch needs to be writable to www-data as well

  $aetitle = "";
  if (isset($_POST['aetitle'])) {
    $aetitle = $_POST['aetitle'];
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " AETitle found\n");
  }
  if ($aetitle === "") {
    echo ("Error: no AETitle found");
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " no AETitle found\n");
    $aetitle = "ProcTESTTEST";
    //return;
  }
  $filename = "bla";
  if (isset($_POST['filename'])) {
    $filename = $_POST['filename'];
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " filename found\n");
  } else {
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " no filename in post\n");
  }

  if (isset($_FILES)) {
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " found theFile in _FILES\n");
  } else {
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " no theFile in _FILES\n");
  }

  $ip = "";
  if (isset($_SERVER['REMOTE_ADDR'])) {
     $ip = $_SERVER['REMOTE_ADDR'];
  }

  function tempdir($dir, $prefix='', $mode=0700)
  {
    if (substr($dir, -1) != '/') $dir .= '/';

    do
    {
      $path = $dir.$prefix.mt_rand(0, 9999999);
      // file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " try this path " . $path);

    } while (!mkdir($path, $mode));

    return $path;
  }


  if ($_FILES["theFile"]["error"] > 0) {
    echo "Error: " . $_FILES["theFile"]["error"] . "<br>";
    //file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") ." upload error, maybe file is too large? Check php.ini. \"" . $aetitle. "\" \"" .$_FILES["theFile"]["error"]. "\"");
  } else {
    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . "file found:" . $_FILES["theFile"]["name"]);

    // create a temp directory in /data/scratch/
    $dir = tempdir("/data/scratch/", "tmp.", 0777);

    file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . "created directory:" . $dir);

    move_uploaded_file($_FILES["theFile"]["tmp_name"], $dir . "/" . $_POST["filename"]);
    $zip = new ZipArchive();
    if ($zip->open($dir . "/" . $_POST["filename"]) === TRUE) {
        file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " try to unzip files to " . $dir);
        $zip->extractTo($dir);
        $zip->close();
        unlink($dir . "/" . $_POST["filename"]);
        file_put_contents($dir . "/info.json", "{ \"ip\": \"$ip\", \"AETitleCalled\": \"$aetitle\" }");

        // process.sh <aetitle caller> <aetitle called> <caller IP> <dicom directory>"
        exec("/usr/bin/bash -c --login '/data/streams/bucket01/process.sh \"mb-shell\" $aetitle $ip \"$dir\"'");
    } else {
        file_put_contents("/tmp/bla", file_get_contents("/tmp/bla") . " could not open zip file " . $_FILES["theFile"]["tmp_name"]);
    }

  }

?>
