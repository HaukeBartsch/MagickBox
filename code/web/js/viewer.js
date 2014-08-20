jQuery(document).ready(function() {
    // alert('page loaded');
});


var app = new DcmApp('view-area');

function load_urllist_from_url(url) {
    app.load_urllist_from_url(url);
}

function testscroll(i, len) {
    if(i > len-1)
        return;
    app.curr_file_idx = i;
    app.draw_image();
    setTimeout((function(a, b) { 
        return function() {
            testscroll(a, b);
        }})(i+1, len), 50);
}

$(document).ready(function() {
    app.init();

    $("#test-scroll").click(function() {
        testscroll(0, app.files.length);
    });
    // Setup cluts
    for(clut in cluts) {
        $("#clut-select optgroup").append($("<option>").val(clut).text(clut));
    }

        // Setup tools
    for(tool in tools) {
        var button = $("<div>").addClass("btn btn-default").text(tool);
        $("#button-bar-horz").prepend(button);
        $(button).click(function() {
            $(this).parent().find("div").removeClass("butt-selected");
            $(this).addClass("butt-selected");
            app.activate_tool(this.innerHTML);
        });
    }

    $("#slider").slider();

    $("button").button();

    $("#axial-view").buttonset();

    $("#view-metadata").click(function() {
        app.fill_metadata_table();
        $("#metadata-dialog").dialog({
            modal: true,
            width: 650,
            buttons: {
                'Ok': function() {
                    $(this).dialog('close');
                }
            }
        });
    });

    $("#open").click(function() {
        $("#open-dialog").dialog({
            modal: true,
            buttons: {
                'Ok': function() {
                    var file_input = $("input[type=file]")[0];
                    app.load_files(file_input.files);
                    $(this).dialog('close');
                },
                'Cancel': function() {
                    $(this).dialog('close');
                }
            }
        });
    });
    $("#butt-reset").click(function() {
        app.reset_levels();
    });
    $("#clut-select").change(function() {
        app.set_clut($(this).val());
    });
    $("#window-presets").change(function() {
        app.set_window_preset($(this).val());
    });
    function handleDragOver(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
    }
    function handleFileSelect(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        app.load_files(evt.dataTransfer.files);
    }

        // Setup the dnd listeners.
    var dropZone = document.getElementById('filebox');
    dropZone.addEventListener('dragover', handleDragOver, false);
    dropZone.addEventListener('drop', handleFileSelect, false);
        //webGLStart();

    // read in the files from the server
    for (var i=0;i<files.length;++i) {
        app.load_url(files[i], i, files.length);
    }

});
