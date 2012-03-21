var kuva = {
    service: {
	url: document.location.host
    }
}

var photos = (function declare_photos () {
    var that = function initialize_photo(options) {
	
    }, reader = lib.reader(), gadgets = [];
    
    // Setup listeners
    reader.onprogress = function(event) {
	gadgets[this.index()].dispatch('progress', event);
    };

    reader.onabort = function(event) {
	gadgets[this.index()].dispatch('abort', event);
    };

    reader.onloadstart = function(event) {
	gadgets[this.index()].dispatch('loadstart', event);
    };

    reader.onloadend = function(event) {
	gadgets[this.index()].dispatch('loadend', event);
	setTimeout(function () {
	    reader.next();
	}, 500);
    };

    function change (event) {
	var i = this.files.length, instance = null;
	while (i--) {
	    instance = gadget();
	    instance.show();
	    gadgets.push(instance);   
	}
	reader.read(this.files);
    }    

    // Setup commands
    function abort () {
	reader.abort();
    }
    
    function initialize() {
	$('#files').bind('change', change);
	$('#abort').bind('click', abort);
	$.jqotetag('*');
	uploader('#files', {thumbnailer: reader});
    }		     			 

    $(initialize);
      
    return that;
})();