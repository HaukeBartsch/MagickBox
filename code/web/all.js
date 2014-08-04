function removeThis( name ) {
    jQuery.get('/code/php/deleteStudy.php?scratchdir='+name, function (data) {
	alert('Result:'+data);
        location.reload();
    });
}

var editor = null;

function zeroPad(num,places) {
    var zero = places - num.toString().length + 1;
    return Array(+(zero > 0 && zero)).join("0") + num;
}

jQuery(document).ready(function() {
    //jQuery('#changeSetup').dialog({  modal: true, autoOpen: false });
    //jQuery('#setup').click(function() {
    //    jQuery('#changeSetup').dialog( "open" );
    //});
    $("#searchClear").click(function(){
	$("#search").val('');
        search();
    });

    jQuery('#alpha-search a').click(function() {
        jQuery('#alpha-search a').each( function( index ) {
            jQuery(this).removeClass('active');
	});
        jQuery(this).addClass('active');
        // now search for patient id's that start with the letter
        if ( jQuery(this).text() == "CLEAR" ) {
	    // display all entries
            jQuery('#projects li').each(function(index) {
		jQuery(this).show();
	    });
	} else {
	    var letter = jQuery(this).text();
            jQuery('#projects li').each(function(index) {
                var t = jQuery(this).attr('patientid');
	        if (t.indexOf(letter) == 0) {
		    jQuery(this).show();
		} else {
		    jQuery(this).hide();
		}
	    });
	}
    });

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
	      var time = "";
  	      if (d['processingLast']<60*60) {
  		  time = " <span class='label label-info'>"
		      + "<span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
		    + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated less than 60min ago)</span>":"")
		    + "</span>";
	 	  if (d['processingLast']<10*60) {
		      time = " <span class='label label-warning'>"
		      + "<span class='processingLogSize'>" + (d['processingLogSize']?d['processingLogSize'] + "byte":"") + "</span>"
		      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated less than 10min ago)</span>":"")
		      + "</span>";
	          }
	 	  if (d['processingLast']<60) {
		      time = " <span class='label label-danger'>"
			  + "<span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
		      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated less than 1min ago)</span>":"")
		      + "</span>";
	          }
	      } else {
		  time = " <span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
		      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min.</span>":"")
		      + "</span>";
	      }
	
          jQuery('#projects').append("<li patientid=\"" + d['pid'] + "\">"
				       +"<button type=\"button\" title=\"remove this entry\" class=\"pull-right btn btn-warning remove-process-data\" data=\""
				       +d['scratchdir']
				       +"\" onclick=\"removeThis('"+d['scratchdir']+"')\"><span class=\"glyphicon glyphicon-trash\"></span></button>"
				       +"<a title=\"If output has been generated click to download as zip\" class=\"pull-right btn btn-info btn-small\" href='/code/php/getOutputZip.php?folder="+d['scratchdir']+"'><span class=\"glyphicon glyphicon-download\"></span> OUTPUT</a>"
				       +"<a title=\"View\" class=\"pull-right btn btn-info btn-small\" href='/code/web/viewer.php?case="+d['scratchdir']+"'><span class=\"glyphicon glyphicon-eye-open\"></span> VIEW</a>"
                                       +"<h4 title=\"Patient ID\">"
				       +"<span class=\"label label-default\">" + zeroPad(i,3) + "</span>&nbsp;"
				       +d['pid']
                                       +"&nbsp;<small>["+d['received']+"]</small>"
				       +"</h4>"
                                       +"<a class=\"label label-info\" title=\"Link to processing log file\" target='_logfile' href='/scratch/"
				       +d['scratchdir']+"/processing.log'>Logfile: "
				       +d['AETitleCalled']
				       +" <- "
				       +d['AETitleCaller']
				       +"</a>"
				       + time
				       +"</li>");
            
	    });
        search();
        setTimeout( function(data) { timeOverview(data); }, 200, data );

        // update alphanumeric search list
        jQuery('#alpha-search a').each(function(index){
            var letter = jQuery(this).text();
            if (letter == "CLEAR") {
                return true;
            }
            var entry = jQuery(this);
            entry.addClass('notthere');
            jQuery.each(data, function(i,d) {
                if (d['pid'].indexOf(letter) == 0) {
                    entry.removeClass('notthere');
                    return false;
                } 
            });
        });
    });

    jQuery.getJSON('/code/php/getStatus.php', function(data) {
	    for ( var i = 0; i < data.length; i++) {
            if (data[i].length < 3)
		continue;
            if (data[i][2] == 0)
   	        jQuery('#statusrow').append("<span class='label label-default' title='" + data[i][0] + "'>"+data[i][1]+(data[i][2]>1?"/"+data[i][2]:"") + " </span>");
	    else
   	        jQuery('#statusrow').append("<span class='label label-warning' title='" + data[i][0] + "'>"+data[i][1]+(data[i][2]>1?"/"+data[i][2]:"")+" </span>");
	    }
    });
  
    jQuery('#search').change(function() {
	search();
    });
});

function timeOverview( data ) {

   // get width
   var el = jQuery('#timeOverview');
   var w = jQuery(el).width();
   var h = jQuery(el).height();

   // create time stamp information
   /*{
    "timestamp": value,
    "timestamp2": value2,
    ...
   }*/
   var caldata = {};
   for (var i = 0; i < data.length; i++) {
      var ts    = data[i]['received'].replace(/ +(?= )/g,'');
      var year  = ts.split(' ').splice(-1)[0];
      var day   = ts.split(' ').splice(2)[0];
      var month = ts.split(' ').splice(1)[0];
      var m = { Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5, Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 };
      timestamp = new Date(year, m[month], day).getTime()/1000;
      if (typeof(caldata[timestamp]) !== 'undefined')
        caldata[timestamp] = caldata[timestamp] + 1;
      else
        caldata[timestamp] = 1;
   }

   var cal = new CalHeatMap();
   cal.init({
     itemSelector: "#timeOverview",
     domain: "month", // try with "week" as well
     subdomain: "x_day",
     cellSize: 15,
     cellPadding: 3,
     cellRadius: 5,
     domainGutter: 15,
     range: 6,
     displayLegend: false,
     data: caldata,
     label: {
         position: "top"
     },
     itemName: ["session", "sessions"]
   });
   cal.previous(5);

    jQuery('svg rect').click(function() {
        var a = jQuery(this).next();
        var b = a.text();
        if (b.split(' ').length > 4) {
            var d = b.split(/[\ ,]/).splice(3);
            var month = d[1].substr(0,3);
            var day = d[2];
            jQuery('#search').val(month + " " + day);
	    search();
        }
    });
}

function search() {
	var term = jQuery('#search').val();
        jQuery('#projects li').each(function() {
	    jQuery(this).show();
	});
        if (term == "") {
	    return true;
	}
        var re = new RegExp(term);
	jQuery('#projects li').each(function() {
            var hide = true;
            var c = jQuery(this).children();
            for (var i = 0; i < c.length; i++) {
		var b = c[i];
		var v = jQuery(b).val();
                v = v.replace(/\ +/g,' ')
		if (v.match(re) != null) {
                    hide = false;
		}
		var v = jQuery(b).text();
                v = v.replace(/\ +/g,' ')
		if (v.match(re) != null) {
                    hide = false;
		}
	    }
            if (hide == true)
		jQuery(this).hide();
	});
}
