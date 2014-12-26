<!DOCTYPE html>
<html>
  <head>
    <title>Processing Overview Page</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="/code/web/css/jquery-ui.min.css" />
    <link href="/code/web/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/code/web/all.css" rel="stylesheet" media="screen">

<!-- test for calendar application -->
<script type="text/javascript" src="/code/web/js/d3.v3.min.js"></script>
<script type="text/javascript" src="/code/web/js/cal-heatmap.min.js"></script>
<link rel="stylesheet" href="/code/web/css/cal-heatmap.css" />
<!-- ----------------------------- -->

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
          <a class="navbar-brand" href="#">Magick Box [#<span title="number of studies processed" class="number-of-studies"></span>]</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Home</a></li>
            <li><a id="pacs-link" href="localhost:1234/dcm4chee-web3" target="_PACS" title="Open DCM4CHEE storage on this machine">PACS</a></li>
      <!--      <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li> -->
            <li class="dropdown">
               <a class="dropdown-toggle" data-toggle="dropdown" href="#">
		 Documentation <span class="caret"></span></a>
               <ul class="dropdown-menu">
                  <li><a class="label-info" target="presentation" href="http://magickbox.readthedocs.org/en/latest/">Read the docs</a></li>
                  <li><a class="label-info" target="presentation" href="/code/documentation/presentation/index.html">Presentation</a></li>
               </ul>
            </li>
            <li class="dropdown">
               <a class="dropdown-toggle" data-toggle="dropdown" href="#">
		 Installed Buckets <span class="caret"></span></a>
               <ul class="dropdown-menu" id="installed-buckets">
                  <li><a id="link-to-bucket-store" class="label-info" href="">Bucket Store</a></li>
               </ul>
            </li>
            <li class="dropdown">
               <a class="dropdown-toggle" data-toggle="dropdown" href="#">
	          Admin <span class="caret"></span></a>
               <ul class="dropdown-menu" id="installed-buckets">
                  <li><a id="restart-services" class="label-info" href="">Restart Services</a></li>
               </ul>
            </li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li><a id="setup" data-toggle="modal" href="#changeSetup">Setup</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>


    <div class="container" style="margin-top: 60px;">
      <div class="row-fluid">
        <!-- <h2>Number of studies available: <span class="number-of-studies"></span></h2> -->

        <div class="pull-right"><div style="z-index: 100;" class="btn-group"><input id="search" type="search" class="form-control" placeholder="search"><span id="searchClear" class="glyphicon glyphicon-remove-circle"></span></div></div>
        <div id="statusrow"></div>
        <div id="timeOverview"></div>
     </div>
      <div class="row-fluid">

        <div id="alpha-search" class="alpha-search">
          <ul>
             <li style="padding-top: 0px;">Processing Logs&nbsp;&nbsp;</li>
             <li><a href="#">CLEAR</a></li>
             <li><a href="#">A</a></li>
             <li><a href="#">B</a></li>
             <li><a href="#">C</a></li>
             <li><a href="#">D</a></li>
             <li><a href="#">E</a></li>
             <li><a href="#">F</a></li>
             <li><a href="#">G</a></li>
             <li><a href="#">H</a></li>
             <li><a href="#">I</a></li>
             <li><a href="#">J</a></li>
             <li><a href="#">K</a></li>
             <li><a href="#">L</a></li>
             <li><a href="#">M</a></li>
             <li><a href="#">N</a></li>
             <li><a href="#">O</a></li>
             <li><a href="#">P</a></li>
             <li><a href="#">Q</a></li>
             <li><a href="#">R</a></li>
             <li><a href="#">S</a></li>
             <li><a href="#">T</a></li>
             <li><a href="#">U</a></li>
             <li><a href="#">V</a></li>
             <li><a href="#">X</a></li>
             <li><a href="#">Y</a></li>
             <li><a href="#">Z</a></li>
             <li>&nbsp;&nbsp;&nbsp;&nbsp;</li>
          </ul>
        </div>
      </div>
      <div class="row-fluid">
        <ul id="projects" style="list-style-type: none; margin-left: -40px;"></ul>
      </div>
      <hr>
      <div class="row-fluid">
         <h2>How to submit data</h2>
         <p>Use DICOM Send to submit data for processing (port 11113). Use the appropriate AETitle to select the corresponding processing bucket:</p>
         <ol class="table table-stipped" id="installed-buckets-list-large">

         </ol>
         <p>After successful processing most buckets send data back to the sending entity.</p>
      </div>
      <hr>
      <div class="row-fluid">
        <footer>
            <p>&copy; Multi-Modal Imaging Laboratory, 2013</p>
        </footer>
      </div>
    </div>

  <div id="changeSetup" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
     <div class="modal-dialog">
        <div class="modal-content">
           <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h4 class="modal-title">Change Setup</h4>
        </div>
        <div class="modal-body">
           <p class="validateTips">Enter the parent's IP (use ifconfig to find out your IP).</p>
           <form>
             <fieldset>
              <label for="IP" style="width: 100px;">Name:</label>
              <input type="text" name="IP" id="IP" placeholder="192.168.0.1" class="text ui-widget-content ui-corner-all" /><br/>
              <label for="PORT" style="width: 100px;">Port:</label>
              <input type="text" name="PORT" id="PORT" placeholder="11112" class="text ui-widget-content ui-corner-all" /><br/>
              <label for="WEBPORT" style="width: 100px;" title="Port under which the webpage is accessible, usually something like 2813.">WebPort:</label>
              <input type="number" name="WEBPORT" id="WEBPORT" placeholder="2813" class="text ui-widget-content ui-corner-all" /><br/>
             </fieldset>
              <hr>
              <p class="validateTips">Delete data if hard drive is too full?</p>
             <fieldset>
              <label for="SCRUBenable" style="width: 100px;" title="Should data be deleted?">Enable:</label>
              <input type="checkbox" name="SCRUBenable" id="SCRUBenable" class="text ui-widget-content ui-corner-all" /><br/>
              <label for="SCRUBhighwaterborder" style="width: 100px;" title="High-water border for deleting data (percentage of space available).">High water border:</label>
              <input type="number" name="SCRUBhighwaterborder" id="SCRUBhighwaterborder" placeholder="90" class="text ui-widget-content ui-corner-all" /><br/>
              <label for="SCRUBlowwaterborder" style="width: 100px;" title="Low-water border when deleting data stops (percentage of space available).">Low-water border:</label>
              <input type="number" name="SCRUBlowwaterborder" id="SCRUBlowwaterborder" placeholder="80" class="text ui-widget-content ui-corner-all" />
             </fieldset>
           </form>
           <hr/>

           <h3>Routing information:</h3>
           <p>Routing is sending data out after processing. Where DICOM files end up might depend on the success or failure of the processing step.</p>
           <div id="editor" style="height: 300px;">load routing information<br/></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
          <button id="setupSaveChanges" type="button" data-dismiss="modal" class="btn btn-primary">Save changes</button>
        </div>
      </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
  </div><!-- /.modal -->



    <script src="/code/web/js/ace/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="/code/web/js/jquery-1.10.2.min.js"></script>
    <script src="/code/web/js/jquery-ui.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/code/web/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/code/web/all.js"></script>
 
  </body>


</html>
