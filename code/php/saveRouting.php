<?php
  // save the file containing the new routing information
  if ( isset($_GET['text']) ) {
  	$objs = json_decode($_GET['text'], true);
  	if ($objs == null) {
  		echo "Error: could not parse this json file";
  	} else {
  	    file_put_contents('/data/code/bin/routing.json', json_encode($objs));
  	}
  }

?>