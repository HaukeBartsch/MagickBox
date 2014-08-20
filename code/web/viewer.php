<!DOCTYPE html>
<html>
  <head>
    <title>Viewer</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="/code/web/css/jquery-ui.min.css" />
    <link href="/code/web/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link rel="stylesheet" type="text/css" href="jsdicom/main.css" />

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="../../assets/js/html5shiv.js"></script>
      <script src="../../assets/js/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
<?php
  // find all dicom files in the output folder of that scratch folder
  $case = "";
  if (isset($_GET['case'])) {
     $case = $_GET['case'];

     $di = new RecursiveDirectoryIterator('/data/scratch/' . $case,RecursiveDirectoryIterator::KEY_AS_PATHNAME);  
     echo ("<script>\n var files = [];\n");
     foreach (new RecursiveIteratorIterator($di,RecursiveIteratorIterator::SELF_FIRST,RecursiveIteratorIterator::CATCH_GET_CHILD) as $filename => $file) {
        if (is_dir($filename))
          continue;
        $extension = pathinfo($filename, PATHINFO_EXTENSION);
        if ($extension == 'dcm') {
          echo(" files.push(\"/" . implode("/",array_splice(explode("/",$filename),2)) . "\");\n");
        }
     }
     echo ("</script>");
  } else {
     echo("<script> var files = []; </script>");
  }

?>


    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Magick Box Image Viewer</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="/index.php">Home</a></li>
        </div><!--/.nav-collapse -->
      </div>
    </div>


    <div class="container" style="margin-top: 100px;">
      <div class="row-fluid">

    <div id="filebox" class="box">
        <div class="box-content">
            <!-- <div id="open" class="tool-button">Open</div> -->
            <!-- <div id="browse" class="tool-button">Browse PACS</div> -->
            <ul id="series-selection"></ul>
        </div>
    </div>
    <div id="viewer" class="box">
        <div id="viewer-bar">
            <div id="view-metadata" class="btn btn-default">Metadata</div>
            <div id="test-scroll" class="btn btn-default">Slide through</div>
            <select id="clut-select">
                <optgroup label="CLUT">
                </optgroup>
            </select>
            <select id="window-presets">
                <optgroup label="Window presets">
                </optgroup>
            </select>
            <div id="button-bar-horz">
                <div id="butt-reset" class="btn btn-default">Reset</div>
            </div>
        </div>

        <div class="slider-holder">
            <div id="slider"></div>
        </div>
        <div id="view-area">
        </div>
    </div>

      </div>
    </div>
    <!-- Dialogs -->
    <canvas id="secondary_canvas" width="512" height="512" style="display: none;"></canvas>
    <div id="metadata-dialog" title="Metadata" style="display: none;">
        <table id="metadata-table">
            <thead>
                <tr>
                    <td>Tag</td>
                    <td>Name</td>
                    <td>Value</td>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>



    <script src="/code/web/js/jquery-1.10.2.min.js"></script>
    <script src="/code/web/js/jquery-ui.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/code/web/js/bootstrap.min.js"></script>

    <script type="text/javascript" src="jsdicom/js/glMatrix-0.9.5.min.js"></script>
    <script type="text/javascript" src="jsdicom/js/glpainter.js"></script>
    <script type="text/javascript" src="jsdicom/js/shaders.js"></script>
    <script type="text/javascript" src="jsdicom/js/canvaspainter.js"></script>
    <script type="text/javascript" src="jsdicom/jquery/js/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="jsdicom/jquery/js/jquery-ui-1.8.20.custom.min.js"></script>

    <!-- External jsdicom-lib -->
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/dcmdict.js"></script>
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/binutils.js"></script>
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/dcmfile.js"></script>
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/dicomparser.js"></script>
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/transfersyntax.js"></script>
    <script type="text/javascript" src="jsdicom/jsdicom-lib/src/qr.js"></script>

    <script type="text/javascript" src="jsdicom/js/GLU.js"></script>
    <script type="text/javascript" src="jsdicom/js/cluts.js"></script>
    <script type="text/javascript" src="jsdicom/js/app.js"></script>
    <script type="text/javascript" src="jsdicom/js/tools.js"></script>
    <script type="text/javascript" src="jsdicom/js/utilities.js"></script>
    <script type="text/javascript" src="jsdicom/js/dcmseries.js"></script>
    <script type="text/javascript" src="jsdicom/js/presentation.js"></script>

    <script type="text/javascript" src="/code/web/js/viewer.js"></script>
 

  </body>


</html>
