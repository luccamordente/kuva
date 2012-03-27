var image = (function () {
    var that = function (element) {
	instance = {
	    element: (element && element[0] || element) || new Image()
	};
	return $.extend(instance, inherit(image), inherit(resizable));
    };
    
    var image = {
	hide: function () {
	    this.element.style.display = 'none'; 
	    return this;
	},
	show: function () {
	    this.element.style.display = 'block'; 
	    return this;
	},
	source: function (source, callback) {
	    if (!arguments.length) return this.element.getAttribute('src');
	    this.element.setAttribute('src', source);
	    return callback && this.loaded(callback);
	},
	on: function (event, callback) {
	    // TODO More compatible on + event callback
	    this.element['on' + event] = callback;
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