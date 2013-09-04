<?php

  if (!isset($_GET['command'])) {
     echo "ERROR: no command\n";
     return;
  }
  $command = $_GET['command'];

  $value = "";
  if (isset($_GET['value'])) {
     $value = $_GET['value'];
  }

  $fn = '/data/code/setup.sh';
  if ( $command == "get" ) {
     echo file_get_contents($fn);
     return;
  } else if ($command == "set") {
     if ($value == "") {
         echo "Error: no value to set\n";
         return;
     }
     if (!is_writable($fn)) {
        echo "Error: no permissions to write file";
     } else {
        echo "overwrite content now";
        file_put_contents($fn, $value);    
     }
  } else {
     echo "Error: unknown command (get/set)";
  }
  
?>