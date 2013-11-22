<!DOCTYPE html>
<html>
  <head>
    <title>Processing Overview Page</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="/code/web/css/jquery-ui.min.css" />
    <link href="/code/web/css/bootstrap.min.css" rel="stylesheet" media="screen">

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

        <div id="statusrow"></div>

        <h2>Processing Logs</h2>
        <ol id="projects"></ol>

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
              <input type="text" name="PORT" id="PORT" placeholder="11112" class="text ui-widget-content ui-corner-all" />
             </fieldset>
           </form><br/>

           <h3>Routing information:</h3>
           <div id="editor" style="height: 300px;">load routing information<br/></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
          <button id="setupSaveChanges" type="button" class="btn btn-primary">Save changes</button>
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
