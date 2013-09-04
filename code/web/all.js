function removeThis( name ) {
    jQuery.get('/code/php/deleteStudy.php?scratchdir='+name, function (data) {
	alert('Result:'+data);
        location.reload();
    });
}

jQuery(document).ready(function() {
    jQuery.getJSON('/code/php/getInstalledBuckets.php', function(data) {
	for (var i = 0; i < data.length; i++) {
            jQuery('#installed-buckets').append("<li><a href='#'>" + data[i] + "</a></li>");
	}
	for (var i = 0; i < data.length; i++) {
            jQuery('#installed-buckets-list-large').append("<li class=\"table-row\">AETitle: (unknown), Folder: " + data[i] + "</li>");
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
	jQuery('#setup').attr('title', data);
    });

    jQuery('#setupSaveChanges').click(function() {
	var valid = true;
	var IP = jQuery('#IP').val();
	var PORT = jQuery('#PORT').val();
        var str = "PARENTIP="+IP+";PARENTPORT="+PORT+";";
	jQuery.get('/code/php/setup.php?command=set&value='+str, function(data) {
		alert(data);
            jQuery.get('/code/php/setup.php?command=get', function(data) {
		    jQuery('#setup').text(data);
		});

	});
	jQuery('#changeSetup').dialog( "close" );
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
                                       +"<a title=\"Link to processing log file\" href='/scratch/"
				       +d['scratchdir']+"/processing.log'>["
				       +d['received']+"] "
				       +d['AETitleCalled']
				       +" -- "
				       +d['CallerIP']
				       +"</a>"
				       +"<br/>If output has been generated download here: <a href='/code/php/getOutputZip.php?folder="+d['scratchdir']+"'>OUTPUT</a> (.zip)"
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
