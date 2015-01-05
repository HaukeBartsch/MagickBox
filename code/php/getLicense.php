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

  echo( file_get_contents("http://mmil.ucsd.edu/MagickBox/queryLicense.php?operation=".$operation."&feature=".$feature."&callback=".$callback."&_=".$nocache) );
  return;

?>