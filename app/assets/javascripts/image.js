var image = (function () {
    var that = function (element) {
	element.element = (element && element[0] || element) || new Image();
	return $.extend(element, inherit(image), inherit(resizable));
    };
    
    var image = {
	hide: function () {
	    this[0].style.display = 'none'; 
	    return this;
	},
	show: function () {
	    this[0].style.display = 'block'; 
	    return this;
	},
	source: function (source, callback) {
	    this[0].setAttribute('src', source);
	    callback && this.loaded(callback);
	},
	loaded: function (callback) {
	    // TODO More compatible onload callback
	    this.onload = callback;
	}
    };


    if (Modernizr.canvas) {
	var resizable = {
	    resize: function (width, height) {
		
	    }
	};
    } else {
	
    }

    return that;
}).call(photos);