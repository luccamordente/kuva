var photos = (function declare_photos () {
    var that = function initialize_photo(options) {

    }, reader = null;

    // Display outputs of this page
    var view = {
	reader: {
	    progress: function() {
		console.log(".");
	    },
	    abort: function(event) {
		console.log(event);
		// console.log(reader.file.name + " cancelado!");
	    },
	    loadstart: function(e) {
		console.log("start");
	    },
	    load: function (event) {
		var file = event.target.file;
		if(file.type.match("image.*"))
		    view.photo({
			src: event.target.result,
			name: file.name
		    });

		console.log(file.name + " loaded!!");
	    },
	    loadend: function() {
		    setTimeout(function () {
			reader.next();
		    }, 500);
	    }
	},
	uploader: {},
	photo: function (options) {
	    $("#photos").jqoteapp("#image-template",{
		src: options.src,
		name: options.name
	    }, '*');
	}
    };

    // Receives user input
    var control = {
	initialize: function () {
	    reader = lib.reader();

	    for (handler in view.reader) {
		reader['on' + handler] = view.reader[handler];
	    }

	    $('#files').bind('change', control.changed);
	    $('#abort').bind('click', control.aborted);

	    uploader('#files', {uploader: '/photos'});
	},
	changed: function () {
	    reader.read(this.files);
	    uploader().upload();
	},
	aborted: function () {
	    reader.abort();
	}
    };


    function initialize() {
	control.initialize();
	$.jqotetag('*');
    }

    $(initialize);

    return that;
})();