var image = (function () {
    var that = function () {
	return inherit(image);
    };
    
    var image = inherit({
	loaded: function (callback) {
	    this.onload = callback;
	}
    });


    if (Modernizr.canvas) {
	var resizable = inherit({
	    resize: function (width, height) {
		
	    }
	});
    } else {
	
    }

    return that;
}).call(photos);