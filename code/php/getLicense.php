<?php

  $operation = "request";
  $feature = "";
  $type = "jsonp";
  $callback = "";
  $nocache = "_";

  if (isset($_GET['operation'])) {
    $operation = $_GET['operation'];
  }
  if (isset($_GET['feature'])) {
    $feature = $_GET['feature'];
  }
  if (isset($_GET['type'])) {
    $type = $_GET['type'];
  }
  if (isset($_GET['callback'])) {
    $callback = $_GET['callback'];
  }
  if (isset($_GET['_'])) {
    $nocache = $_GET['nocache'];
  }

  $val = file_get_contents("http://mmil.ucsd.edu/MagickBox/queryLicense.php?operation=".$operation."&feature=".$feature."&callback=".$callback."&_=".$nocache);
  if ( $val == FALSE || intval(json_decode($val,TRUE)['contingent']) < 1) {
    $gfile = "/data/scratch/.grace_".$feature;
    $grace = file_get_contents($gfile);
    if ($grace == FALSE) {
       $val = 20;
       $grace = strval($val);
       $ret = file_put_contents($gfile, $grace);
       if ($ret == FALSE) {
          // could not write grace file, give up
          $ret = array( "feature" => $feature, "contingent" => $grace, "message" => "System error, giving up...".$gfile );
	  echo ( json_encode($ret) );
	  return;
       }
    }
    $val = intval($grace);
    // if we query we don't need to change the grace period
    if ($operation !== "query") {
      $ret = file_put_contents($gfile, strval($val - 1));
      if ($ret == FALSE) {
         $ret = array( "feature" => $feature, "contingent" => "0", "message" => "Error: could not update, grace period, giving up. Contact MMIL at UC San Diego" );
         echo ( json_encode($ret) );
         return;
      }
    }
    if ($val < 1) {
       $ret = array( "feature" => $feature, "contingent" => "0", "message" => "Trace period ended, please contact the Multi-modal Imaging Laboratory, at UC San Diego");
       echo ( json_encode($ret) );
       return;
    }
    $val = json_encode(array( "feature" => $feature, "contingent" => $grace, "message" => "You are working inside our grace period. Please contact MMIL UC San Diego for a renewal of your licenses."));
  }

  echo( $val );

  return;

?>