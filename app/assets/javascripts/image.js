var image = (function () {
    var that = function (element, options) {
	instance = {
	    element: (element && element[0] || element) || new Image()
	};
	return $.extend(instance, inherit(image), inherit(resizable), options);
    },
    // TODO add event dispatching support for better context control
    image = {
	context: null,
	size: function (width, height) {
	    width && (this.element.style.width = width);
	    height && (this.element.style.height = height);
	},
	// TODO Sobrescrever método dependendo do brower
	hide: function (duration, easing, callback) {
	    var style = this.element.style;

	    if (Modernizr.csstransitions) style.opacity = 0;
	    else if (arguments.length) $(this.element).fadeOut(duration, easing, callback);
	    else style.display = 'none'; 

	    return this;
	},
	// TODO Sobrescrever método dependendo do brower
	show: function (duration, easing, callback) {
	    var style = this.element.style;
	    
	    if (Modernizr.csstransitions) style.opacity = 1;
	    else if (arguments.length) $(this.element).fadeIn(duration, easing, callback);
	    else style.display = 'block';

	    return this;
	},
	source: function (source, store) {
	    if (!arguments.length) return this.element.getAttribute('src');
	    if (!store) this.element.setAttribute('src', source);
	    else {
		this.result = source;

		// TODO Native onload dispatching
		this.element.onload && this.element.onload({target: this});
	    }	     	     	     	     
	    return this;       
	},
	on: function (event, callback) {
	    // TODO More compatible on + event callback
	    this.element['on' + event] = callback;
	    return this;
	},
	unload: function () {
	    this.source(null);
	    $(this.element).remove();
	    delete this.element;
	    delete this.result;
	    this.element = new Image();
	},
	ratio: function () {
	    return this.element.width / this.element.height;
	}
    };		


    if (Modernizr.canvas) {
	var resizable = inherit(thumbnailer());
	resizable.resize = function (width, height, quality, context) {
	    var options = {context: context || this, type: this.type};
	    (!height) && (height = width / this.ratio());  	
	    (!width) && (width = height * this.ratio());
	    
	    

	    // TODO Better check element presence
	    this.thumbnail(this.result || this.element, width, quality, options);
	}		   						
    } else {
	
    }

    return that;
}).call(photos);