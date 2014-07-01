function removeThis( name ) {
    jQuery.get('/code/php/deleteStudy.php?scratchdir='+name, function (data) {
	alert('Result:'+data);
        location.reload();
    });
}

var editor = null;

jQuery(document).ready(function() {
    //jQuery('#changeSetup').dialog({  modal: true, autoOpen: false });
    //jQuery('#setup').click(function() {
    //    jQuery('#changeSetup').dialog( "open" );
    //});
    jQuery.getJSON('/code/php/getInstalledBuckets.php', function(data) {
	    for (var i = 0; i < data.length; i++) {
            name = data[i]['name'];
            desc = data[i]['description'];
            jQuery('#installed-buckets').append("<li><a href='#' title=\"" + desc + "\">" + name + "</a></li>");
	    }
	    for (var i = 0; i < data.length; i++) {
            name = data[i]['name'];
            desc = data[i]['description'];
	        aetitle = data[i]['AETitle'];
	        if (typeof aetitle == 'undefined')
		        aetitle = "NONE";
            jQuery('#installed-buckets-list-large').append("<li class=\"table-row\">AETitle: \"" + aetitle + "\", Name: \"" 
							   + name + "\"<br/><small>" + desc +
							   "</small></li>");
	    }
    });

    jQuery.get('/code/php/setup.php?command=get', function(data) {
        // set the values into the dialog as well
        var str = data.split(';');
        if (str.length > 2) {
            str.forEach(function(element, index) {
		                   var str2 = element.split('=');
		                   if (str2.length > 1) {
                              if (jQuery.trim(str2[0]) == "PARENTIP") {
                                  var ip = jQuery.trim(str2[1]);
                                  jQuery('#IP').val(ip);
                                  jQuery('#pacs-link').attr('href', 'http://' + ip + ':1234/dcm4chee-web3/');
                                  jQuery('#link-to-bucket-store').attr('href', 'http://' + ip + ':2813/code/bucketstore/index.php');
                              }
                              if (jQuery.trim(str2[0]) == "PARENTPORT") {
                                  jQuery('#PORT').val(jQuery.trim(str2[1]));
                              }
                           }
	        });
        }
    });

    // get the routing information as well
    jQuery.ajax({
        url: '/code/bin/routing.json', 
        dataType: 'html',  // we want to show this as text not interprete
        success: function(data) {
            if (editor == null) {
                editor = ace.edit("editor");
            }
            editor.setValue(data);
            editor.setTheme("ace/theme/monokai");
            editor.getSession().setMode("ace/mode/javascript");
        },
        cache: false
    });
        
	//jQuery('#setup').attr('title', data);

    jQuery('#restart-services').click(function() {
	    jQuery.get('/code/php/restartServices.php?command=restart&value=storescp', function(data) {
            // restart the storescp system service
	    });
    });

    jQuery('#setupSaveChanges').click(function() {
	    var valid = true;
	    var IP = jQuery('#IP').val();
	    var PORT = jQuery('#PORT').val();
        var str = "PARENTIP="+IP+";PARENTPORT="+PORT+";";
	    jQuery.get('/code/php/setup.php?command=set&value='+str, function(data) {
  		    //alert(data);
            jQuery.get('/code/php/setup.php?command=get', function(data) {
		       jQuery('#setup').attr('title',data);
		    });
	    });

        // also store the routing information again
        jQuery.ajax({
            url: '/code/php/saveRouting.php',
            data: { "text":  editor.getValue() },
            type: 'POST',
            success: function(data){
                if (data.length > 0)
                    alert('Error: ' + data);
            }
        });
    });

    jQuery.getJSON('/code/php/getScratch.php', function(data) {
        jQuery('.number-of-studies').html(data.length);
	    jQuery.each(data, function(i,d) {
            jQuery('#projects').append("<hr><li><h4 title=\"Patient ID\">"
				       +d['pid']
				       +"</h4>"
				       +"<button type=\"button\" class=\"close remove-process-data\" data=\""
				       +d['scratchdir']
				       +"\" onclick=\"removeThis('"+d['scratchdir']+"')\">&times;</button>"
                                       +"<a title=\"Link to processing log file\" target='_logfile' href='/scratch/"
				       +d['scratchdir']+"/processing.log'>["
				       +d['received']+"] "
				       +d['AETitleCalled']
				       +" -- "
				       +d['AETitleCaller']
				       +"</a> <span class='processingLogSize'>" + (d['processingLogSize']?d['processingLogSize'] + "byte":"") + "</span>"
				       + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min.</span>":"")
				       +"<br/>If output has been generated click here to download: <a href='/code/php/getOutputZip.php?folder="+d['scratchdir']+"'>OUTPUT</a> (.zip)"
				       +"</li>");
            
	    });
    });

    jQuery.getJSON('/code/php/getStatus.php', function(data) {
	    for ( var i = 0; i < data.length; i++) {
            if (data[i].length < 3)
		       continue;
            if (data[i][2] == 0)
   	           jQuery('#statusrow').append("<span class='label label-default' title='" + data[i][0] + "'>"+data[i][1]+" </span>");
	        else
   	           jQuery('#statusrow').append("<span class='label label-warning' title='" + data[i][0] + "'>"+data[i][1]+" </span>");
	    }
    });
});
