<!DOCTYPE html>
<html>
  <head>
    <title>Bucket Store</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
    <link href="/code/web/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/code/bucketstore/store.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="../../assets/js/html5shiv.js"></script>
      <script src="../../assets/js/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Bucket Store [#<span title="number of available buckets" class="number-of-buckets"></span>]</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Home</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>


    <div class="container" style="margin-top: 60px;">
      <div class="row-fluid">
	<h1>Bucket Store</h1>

        <ol id="bucket-list">
<?php
   $dirs = array_filter(glob('/data/code/bucketstore/buckets/*'), 'is_dir');
   echo "<script type='text/javascript'>var numBuckets = ".count($dirs).";</script>";
   foreach ($dirs as $d) {
      $vals = json_decode( file_get_contents( $d."/info.json"), true);
      echo "<li class='bucket'><div class='text'>".$vals['name']." - (v". $vals['version'] . ") <br/><a href='".$d."/".$vals['install']."'>DOWNLOAD</a></div></li>";
   }
?>
        </ol>

      </div>

      <div class="row-fluid">
        <hr>
        <h2>Bucket API</h2>
        <p>New buckets can be defined using the attached template. Download the file and unpack into a temporary directory. Copy all your processing scripts into the directory and adjust the info.json file using a text editor.</p>
        <pre>
        {
          "name": "MyPackage",
          "install": "mypackage.tgz",
          "version": "0.0.1"
        }</pre>
        
        <a class="btn btn-primary" role="button" href="/code/bucketstore/bucketAPI.tgz" id="download-bucket-API">Bucket API Template<br/>Linux 64bit, glibc 4.7</a>
      </div>
 
      <div class="row-fluid">
        <hr>
        <footer>
            <p>&copy; Multi-modal imaging laboratory, 2013</p>
        </footer>
      </div>
    </div>


    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="//code.jquery.com/jquery-1.10.1.min.js"></script>
    <script src="//code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/code/web/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="store.js"></script>
 
  </body>

</html>
