//= require library/framework/shims/extend

(function () {
    var that = function (element, options) {
    if (!options) options = '';

	var element = (element && element[0] || element) || new Image(),
	    instance = {
	    element: element
	};

	if (typeof options === 'string') options = {title: options};

	if (options.title || options.title === '') {
	    element.setAttribute('title', options.title);
	    if (!options.alt) element.setAttribute('alt', options.title);
	    delete options.title;
	}

	return $.extend(instance, inherit(image), inherit(resizable), options);
    },
    // TODO add event dispatching support for better context control
    image = {
		context: null,
		// TODO Sobrescrever método dependendo do brower
		hide: function (duration, easing, callback) {
			var style = this.element.style;

			if (Modernizr.csstransitions) style.opacity = 0;
			else if (arguments.length) $(this.element).fadeOut(duration, easing, callback);
			else style.display = 'none';

			return this;
		},
		size: function (width, height) {
			width && (this.element.style.width  = +width + 'px');
			height && (this.element.style.height = +height + 'px');
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
			if (!store) {
				// When there is no source and we're erazing source, do nothing
				// otherwise browser will make a request
				if (!source && !this.element.getAttribute('src')) return this;
				this.element.setAttribute('src', source);
			} else {
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
			this.source('');
			$(this.element).remove();
			delete this.element;
			delete this.result;
			this.element = new Image();
		},
		ratio: function () {
			this.element.width / this.element.height;
		},
		width: function (width) {
			$(this.element).width(width);
		},
		height: function () {
			$(this.element).height(height);
		},
		title: function (title, no_alt) {
			!no_alt && this.element.setAttribute('alt', title);
			return this.element.setAttribute('title', title);
		}
    };

	// TODO inheritables getters and setters throught the inherit method
	// Object.defineProperty(image, 'size', {
	// 	get: function () {
	// 		return {
	// 			width: this.width(),
	// 			height: this.height()
	// 		};
	// 	},
	// 	set: function (value) {
	// 		value[0]  && (this.element.style.width  = +value[0] + 'px');
	// 		value[1] && (this.element.style.height = +value[1] + 'px');
	// 	},
	// 	configurable: true

	// });


    if (!Modernizr.canvas) {
		var resizable = inherit(thumbnailer());
		resizable.resize = function (width, height, quality, context) {
			var options = {context: context || this, type: this.type};
			(!height) && (height = width / this.ratio());
			(!width) && (width = height * this.ratio());

			// TODO Better check element presence
			this.thumbnail(this.result || this.element, width, quality, options);
		}
    } else if (Modernizr.draganddrop) {
		var resizable = {
			resize: function (width, height, quality, context) {

			}
		}
    }

	this.image = that;
}).call(window.library || (window.library = {}));