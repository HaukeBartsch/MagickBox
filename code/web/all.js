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

// removes data from the archive given a study instance uid
function removeArchive( siuid ) {
    jQuery.getJSON('/code/php/deleteStudy.php?SIUID='+ siuid, function(data) {
	alert('tried to remove, got this: ' + data['message']);
    });
}

var boxselected = null;

function fillInProjects( data ) {
        jQuery('.number-of-studies').html(data.length);
	// how wide is our page?
        w = parseInt(jQuery('#projects2').css('width'));
        boxw = 250; // size of a single box
        gaps = Math.floor(w/boxw) - 1;
        boxperrow = parseInt(Math.floor((w - gaps*13)/boxw));
        rowcounter = 0;

        jQuery('#projects2').children().remove(); // clean out the old data
        jQuery('#projects2').append("<div class=\"row-fluid\" id=\"rowcontainer"+rowcounter+"\"></div>");
        trow = jQuery("#rowcontainer"+rowcounter);
	for (var i = 0, inrowcounter = 0; i < data.length; i++, inrowcounter++) {
	    d = data[i];
	    if (inrowcounter >= boxperrow) {
		inrowcounter = 0;
		jQuery('#projects2').append("<div id=\"rowdetail-"+rowcounter+"\" class=\"rowdetail\"></div>");
                rowcounter++;
		// add an empty placeholder for details
                jQuery('#projects2').append("<div class=\"row-fluid\" id=\"rowcontainer"+rowcounter+"\"></div>");
		trow = jQuery("#rowcontainer"+rowcounter);
	    }

  	    if (d['processingLast']<60*60) {
  	    	time = " <span class='label label-info'> "
	    	      + "<span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
	    	    + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated <60min ago)</span>":"")
	    	    + "</span>";
	    	if (d['processingLast']<10*60) {
	    	      time = " <span class='label label-warning'> "
	    	      + "<span class='processingLogSize'>" + (d['processingLogSize']?d['processingLogSize'] + "byte":"") + "</span>"
	    	      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated <10min ago)</span>":"")
	    	      + "</span>";
	        }
	    	if (d['processingLast']<60) {
	    	      time = " <span class='label label-danger'> "
	    		  + "<span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
	    	      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min. (updated <1min ago)</span>":"")
	    	      + "</span>";
	        }
	    } else {
		if (typeof(d['processingLogSize']) == 'undefined') {
                    time = "<span class='processingLogSize'>&nbsp;</span>";
		} else {
  	    	  time = " <span class='processingLogSize'>" + (d['processingLogSize']?(d['processingLogSize']/1024).toFixed(2) + "kbyte":"") + "</span>"
	    	      + (d['processingTime']?" <span class='processingTime'>" + (d['processingTime']/60.0).toFixed(2) + "min.</span>":"")
	    	      + "</span>";
                }
	    }

            str = "<div class=\"box\" detailtarget=\"rowdetail-"+rowcounter+"\" patientid=\""+d['pid']+"\" tmpDir=\""+d['scratchdir']+"\" sender=\""+d['AETitleCaller']+"\" style=\"background-image: url('data:image/png;"+patternList[d['AETitleCalled']]+"');\">";
            str = str + "  <div class=\"aheader\">";
	    str = str + "    <div class=\"pull-right\" title=\"Date/Time the request for processing was received\">" + 
		  d['received'].split(" ").slice(0,4).join(" ") + "</div>";
            str = str + "    <div class=\"number\">" + zeroPad(i,3) + "</div>";
            str = str + "  </div>";
            str = str + "<div class=\"abody\" style=\"background-color: rgba(255,255,255,0.3);\">";
	    str = str + "<span class=\"proctitle\">" + d['AETitleCalled'] + "</span>";
	    str = str + "<br/><span title=\"Send by\">Sender: " + d['AETitleCaller'] + "</span>";
            str = str + "<br/><div title=\"Series Instance UID "+d['pid']+"\">"+smartTrim(d['pid'],30)+"</div>";
            str = str + "</div>";
            str = str + "<div class=\"afooter\">";
	    str = str + time;
            str = str + "<div class=\"pull-right\">";
	    str = str + "    <a title=\"Link to processing log file\" target='_logfile' href='/scratch/" + d['scratchdir'] + "/processing.log' style=\"color: black;\"><span class=\"glyphicon glyphicon-list-alt\" style=\"margin-right: 5px; \"></span></a>";
            str = str + "</div>";
            str = str + "</div>";
            str = str + "</div>";
            trow.append(str);
        }
        // and one more for the last row
	jQuery('#projects2').append("<div id=\"rowdetail-"+rowcounter+"\" class=\"rowdetail\"></div>");

	// and open the currently open detail again
	if (boxselected != null) {
	    console.log("show this box again " + boxselected);
  	    openDetail(boxselected);
        }

}

function smartTrim(string, maxLength) {
    if (!string) return string;
    if (maxLength < 1) return string;
    if (string.length <= maxLength) return string;
    if (maxLength == 1) return string.substring(0,1) + '...';
    var midpoint = Math.ceil(string.length / 2);
    var toremove = string.length - maxLength;
    var lstrip = Math.ceil(toremove/2);
    var rstrip = toremove - lstrip;
    return string.substring(0,midpoint-lstrip) + '...' + string.substring(midpoint+rstrip);
}

var logTimer;
function showDetails( target, siuid, tmpFolder, sender, bucket, number) {

    id1 = target + "-binfo";
    id2 = target + "-logfile";
    jQuery('#'+target).append("<div class=\"col-lg-4 col-md-4 col-sm-6 col-xs-12\" id=\""+id1+"\"></div>");
    jQuery('#'+target).append("<div class=\"col-lg-4 col-md-6 col-sm-6 col-xs-12\" id=\""+id2+"\"></div>");

    // now add information about the bucket as well
    jQuery.getJSON('/code/php/timing.php?aetitle=' + bucket, function(data) {
	console.log(data);
	str = " <h4>" + number + " " + bucket + " Bucket <small title=\"Estimated processing time\">"+ moment.duration(data.avg, "s").humanize() + "</small></h4>";

        str = str + "<a title=\"If output has been generated click to download as zip\" class=\"btn btn-info btn-small btn-block\" href='/code/php/getOutputZip.php?folder="+tmpFolder+"'><span class=\"glyphicon glyphicon-cloud-download\"></span> DOWNLOAD OUTPUT</a>";
        str = str + "<a title=\"View Image Data\" class=\"btn btn-info btn-small btn-block\" href='/code/web/viewer.php?case="+tmpFolder+"'><span class=\"glyphicon glyphicon-eye-open\"></span> VIEW IMAGES</a><br/><br/>";
        str = str +"<button type=\"button\" title=\"remove output folder for this computation\" class=\"btn btn-warning remove-process-data btn-block\" data=\"";
        str = str + tmpFolder;
        str = str + "\" onclick=\"removeThis('"+tmpFolder+"')\"><span class=\"glyphicon glyphicon-trash\"></span> REMOVE OUTPUT</button>";

        str = str +"<button type=\"button\" title=\"remove input for this computation\" class=\"btn btn-warning remove-process-data btn-block\" data=\"";
        str = str + d['scratchdir'];
        str = str + "\" onclick=\"removeArchive('"+siuid+"')\"><span class=\"glyphicon glyphicon-trash\"></span> REMOVE INPUT</button>";
        jQuery('#'+id1).append(str);
    });

    str = "<div class=\"alogfile\">"
    str = str + "Processing log file:<br/><textarea id=\"ta-"+target+"\" rows=\"10\" style=\"width: 100%; color: #BBBBBB; border: 2px solid #cccccc; padding: 5px; font-family: 'Lucida Console', Monaco, monospace; font-size: 9pt; overflow-x: auto;";
    str = str + "-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box;\"></textarea>";
    str = str + "</div>";
    jQuery('#'+id2).append(str);
    // now fill every 10 seconds with data
    var fillText = (function(target) {
        return function() {
  	  jQuery.get('/scratch/' + tmpFolder + '/processing.log', function(data) {
              if (jQuery('#ta-'+target).length > 0) {
  	        var a = jQuery('#ta-'+target)[0].selectionStart;
	        var b = jQuery('#ta-'+target)[0].selectionEnd;
	        jQuery('#ta-'+target).val(data.split('\n').reverse().join('\n'));
	        jQuery('#ta-'+target)[0].setSelectionRange(a, b);
              }
          });
	};
    })(target);
    fillText();
    logTimer = setInterval(function() {
	fillText();
    }, 10000);

    // now query the database for information on this subject (needs sender and scratch)
    jQuery.getJSON('/code/php/db.php?query='+tmpFolder+'&sender='+sender, function(data) {
	if (data == null)
	    return; // just ignore this
        // ok now add a table
	str = "<div class=\"col-lg-4 col-md-6 col-sm-6 col-xs-12\" style=\"margin-top: 20px; height: 120px; overflow-y: scroll; overflow-x: auto;\">";
        keys = Object.keys(data);
        for (var i = 0; i < keys.length; i++) {
	  str = str + "<br/>file: " + keys[i] + "<br/>";
          e = data[keys[i]];
	  ind = Object.keys(e);
          str = str + "<table class=\"table table-hover table-striped\"><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>"
          for (var j = 0; j < ind.length; j++) {
             str = str + "<tr><td>" + ind[j] + "</td><td>" + e[ind[j]] + "</td></tr>";
          }
          str = str + "</tbody></table>";
        }
        str = str + "</div>";
        jQuery('#'+target).append(str);
    });

    if (siuid !== "") {
      jQuery.getJSON('/code/php/getArchive.php?siuid='+siuid, function(data) {
	str = "<div class=\"col-lg-4 col-md-6 col-sm-6 col-xs-12\" style=\"margin-top: 20px; overflow-x: auto;\">";
        keys = Object.keys(data);
        for (var i = 0; i < keys.length; i++) {
	  // str = str + "<br/>file: " + keys[i] + "<br/>";
          e = data[keys[i]];
	  ind = Object.keys(e);
          str = str + "<table class=\"table table-striped table-hover\"><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>"
          for (var j = 0; j < ind.length; j++) {
             str = str + "<tr><td>" + ind[j] + "</td><td>" + e[ind[j]] + "</td></tr>";
          }
          str = str + "</tbody></table>";
        }
        str = str + "</div>";
        jQuery('#'+target).append(str);
      });
    }

}

function openDetail( target ) {
	var t = jQuery(target).attr('detailtarget');
	var patientid = jQuery(target).attr('patientid');
	var tmpFolder = jQuery(target).attr('tmpDir');
        var sender    = jQuery(target).attr('sender');
	var bucket    = jQuery(target).find('.proctitle').text();
        var number    = jQuery(target).find('.number').text();

	var h = parseInt(jQuery('#'+t).css('height'));
	if (h > 0 && boxselected == target) { // already open, close it now - or switch to new entry
	   jQuery('.rowdetail').children().remove();
	   jQuery('.rowdetail').animate({
   		   height: 0
	   });
   	   if (typeof(logTimer) !== 'undefined')
	      clearInterval(logTimer);
           jQuery(target).removeClass('activeBox');
	   boxselected = null;
	   return;
        }
	boxselected = target;

	// find one from before which was marked active
 	jQuery('.box, .activeBox').removeClass('activeBox');

	// close the detail from before (we should delete all the content first)
        jQuery('.rowdetail').each(function(index, r) {
	    if (parseInt(jQuery(r).css('height')) > 0) {
		jQuery(r).children().remove();
   		jQuery(r).animate({ height: 0 });
	    }
	});
	jQuery('#'+t).css('height', 'auto').animate({
		height: 300
	});
  	jQuery(target).addClass('activeBox');
  	if (typeof(logTimer) !== 'undefined')
	   clearInterval(logTimer);
    showDetails( t, patientid, tmpFolder, sender, bucket, number );
}


var patternList = {};

jQuery(document).ready(function() {

    $("#searchClear").click(function(){
	$("#search").val('');
        search();
    });
    jQuery(window).resize(function() {
	if (typeof(allData) !== 'undefined' && allData.length > 0) {
           fillInProjects( allData );
	}
    });
    jQuery('#RemoveStudies').click(function() {
	jQuery('#removestudiestable').children().remove();
        jQuery.getJSON('/code/php/getArchive.php', function(data) {
	    str = "";
	    for (var i = 0; i < data.length; i++) {
                str += "<tr>";
		str += "<td>" + data[i]['PatientID'] + "</td>";
		str += "<td>" + data[i]['AccessionNumber'] + "</td>";
		str += "<td>" + data[i]['StudyDate'] + "</td>";
		str += "<td>" + data[i]['PatientName'] + "</td>";
		str += "<td>" + data[i]['StudyDescription'] + "</td>";
		str += "<td>" + data[i]['SIUID'] + "</td>";
		str += "<td><button class=\"btn btn-default\" onclick=\"removeArchive('"+data[i]['SIUID']+"');\" val=\""+data[i]['SIUID']+"\">Delete Study</button></td>";
                str += "</tr>";
	    }
	    jQuery('#removestudiestable').append(str);
	});
    });

    jQuery('#rlog').click(function() {
	jQuery('#logtable').children().remove();
	jQuery.getJSON('/code/php/getRoutingLog.php', function(data) {
	    // got data from the log, show them as one line each
	    str = "";
	    for (var i = 0; i < data.length; i++) {
		str += "<tr><td>" + data[i] + "</td></tr>";
	    }
	    jQuery('#logtable').append(str);
	});
    });

    jQuery('#alpha-search a').click(function() {
        jQuery('#alpha-search a').each( function( index ) {
            jQuery(this).removeClass('active');
	});
        jQuery(this).addClass('active');
        // now search for patient id's that start with the letter
        if ( jQuery(this).text() == "CLEAR" ) {
	    // display all entries
            jQuery('#projects2 div .box').each(function(index) {
		jQuery(this).show();
	    });
            jQuery('#search').val("");
	} else {
	    var letter = jQuery(this).text();
            jQuery('#projects2 div .box').each(function(index) {
                var t = jQuery(this).attr('patientid');
	        if (t.indexOf(letter.toLowerCase()) == 0) {
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
	    if (typeof(aetitle) == 'undefined')
	        aetitle = "NONE";
            jQuery('#installed-buckets-list-large').append("<li class=\"table-row row" + i + "\">AETitle: \"" + aetitle + "\", Name: \"" 
							   + name + "\"<br/><small>" + desc +
						           "</small>" + "</li>");

	    // lets create a picture for each bucket
	    var pattern = Trianglify({
		width: 250, height: 150, cell_size: 20, seed: aetitle });
	    patternList[aetitle] = pattern.png();

            if (typeof(aetitle) !== 'undefined') { 
              jQuery.get('/code/php/getLicense.php', { operation: "query", feature: aetitle }, function(num){
                return function(data) {
                  jQuery('.row'+num).append(" <span class=\"label label-info\" title=\"Number of available sessions\">" + data.contingent + "</span>");
                };
              }(i), "jsonp");
            }
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
                              if (jQuery.trim(str2[0]) == "WEBPORT") {
                                  jQuery('#WEBPORT').val(jQuery.trim(str2[1]));
                              }
                              if (jQuery.trim(str2[0]) == "SCRUBhighwaterborder") {
                                  jQuery('#SCRUBhighwaterborder').val(jQuery.trim(str2[1]));
                              }
                              if (jQuery.trim(str2[0]) == "SCRUBlowwaterborder") {
                                  jQuery('#SCRUBlowwaterborder').val(jQuery.trim(str2[1]));
                              }
                              if (jQuery.trim(str2[0]) == "SCRUBenable") {
                                  if (jQuery.trim(str2[1]) == "1")
                                      jQuery('#SCRUBenable').prop('checked', true);
				  else
                                      jQuery('#SCRUBenable').prop('checked', false);
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
	    var valid   = true;
	    var IP      = jQuery('#IP').val();
	    var PORT    = jQuery('#PORT').val();
            var WEBPORT = jQuery('#WEBPORT').val();
            var SCRUBhighwaterborder = jQuery('#SCRUBhighwaterborder').val();
            var SCRUBlowwaterborder  = jQuery('#SCRUBlowwaterborder').val();
            var SCRUBenable = "0";
        if (jQuery('#SCRUBenable').is(':checked'))
              SCRUBenable          = "1";
            var str = "PARENTIP="+IP+";PARENTPORT="+PORT+";WEBPORT="+WEBPORT+";SCRUBhighwaterborder="+SCRUBhighwaterborder+";SCRUBlowwaterborder="+SCRUBlowwaterborder+";SCRUBenable="+SCRUBenable+";";
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

    jQuery('#projects2').on("click", ".box", function() {
	openDetail( this );
    });

    jQuery.getJSON('/code/php/getScratch.php', function(data) {
        allData = data;
        fillInProjects( data );

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
                if (d['pid'].indexOf(letter.toLowerCase()) == 0) {
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
   	        jQuery('#statusrow').append("<span class='label label-default' title='" + data[i][0] + "'>"+data[i][2]+(data[i][1]>1?"/"+data[i][1]:"") + " </span>");
	    else
   	        jQuery('#statusrow').append("<span class='label label-warning' title='" + data[i][0] + "'>"+data[i][2]+(data[i][1]>1?"/"+data[i][1]:"")+" </span>");
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
       var ts, year, day, month;
      if ( data[i]['received'].indexOf(',') === -1 ) {
        ts    = data[i]['received'].replace(/ +(?= )/g,'');
        year  = ts.split(' ').splice(-1)[0];
        day   = ts.split(' ').splice(2)[0];
        month = ts.split(' ').splice(1)[0];
      } else {
        ts    = data[i]['received'].replace(/ +(?= )/g,'');
        year  = ts.split(' ').splice(-3)[0];
        day   = ts.split(' ').splice(1)[0];
        month = ts.split(' ').splice(2)[0];
      }
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
/*        jQuery('#projects li').each(function() {
	    jQuery(this).show();
	});  */
        jQuery('#projects2 div').each(function() {
	    jQuery(this).show();
	});

        if (term == "") {
	    return true;
	}
        var re = new RegExp(term);
/*	jQuery('#projects div').each(function() {
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
		var v = jQuery(b).attr("href");
		if (typeof(v) !== 'undefined') {
                  v = v.replace(/\ +/g,' ')
		  if (v.match(re) != null) {
                    hide = false;
		  }
		}
	    }
            if (hide == true)
		jQuery(this).hide();
	}); */
	jQuery('#projects2 div').each(function() {
            var hide = true;

            var c = jQuery(this).children(); // all the entries in a single row
            for (var i = 0; i < c.length; i++) {
		var b = c[i];
  	        jQuery.each(b.attributes, function(index, elem) {
 		   if (elem.value.match(re) != null) {
		       hide = false;
		   }
	        });
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
		var v = jQuery(b).attr("href");
		if (typeof(v) !== 'undefined') {
                  v = v.replace(/\ +/g,' ')
		  if (v.match(re) != null) {
                    hide = false;
		  }
		}
	    }
            if (hide == true)
		jQuery(c).hide();
	});
}
