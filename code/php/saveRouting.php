<?php
  // save the file containing the new routing information
  if ( isset($_POST['text']) ) {
  	$objs = json_decode($_POST['text'], true);
  	if ($objs == null) {
  	  echo "Error: could not parse this json file";
  	} else {
  	  file_put_contents('/data/code/bin/routing.json', json_encode($objs, JSON_PRETTY_PRINT));
  	}
  }
?>