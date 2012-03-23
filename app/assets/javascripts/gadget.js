var gadget = (function declare_photos () {
    var that = function initialize_photo(parent, options) {
	options = options || {};
	options.parent = parent || '#gadgets';
	options.data = options.data || {};
	return $.extend(options, inherit(gadget));
    }, id = 0,    
    gadget = {
	show: function () {
	    !this.element && control.create.call(this);
	    this.element.fadeIn();
	},
	dispatch: function (name, event) {
	    handlers[name] && handlers[name].call(this, event);
	    return this;
	},
	listen: function (name, callback) {
	    this[name] = callback;
	}
    }, control = {
	create: function () {
	    this.data = $.extend({
		id: id++,
		source: 'http://' + kuva.service.url + '/assets/jla.gif',
		title: 'Sumonando'
	    }, this.data);
	    $(this.parent).jqoteapp('#gadget', this.data);
	    this.element = $('#gadget-' + this.data.id);
	    this.image = image(this.element.find('img'));
	    this.bar = this.element.find('.bar');
	}
    },
    handlers = {
	loadstart: function reader_loadstart (event) {
	    this.show();
	    this.element.addClass('loading');
	    console.log(this.element);
	},
	loadend: function reader_loadend (event) {
	    console.log(event);
	    if (event.loaded == event.total) {
		var loading = new Image();

		this.image.source('http://' + kuva.service.url + '/assets/la.gif');
		loading.onload = $.proxy(handlers.loaded, this);
		loading.src = event.target.result;
	    } else {

	    }
	},
	loaded: function image_loaded (event) {
	    var image = event.target, 
	    height = Math.round(image.height * 250 / image.width);
	    
	    this.element.addClass('thumbnailing')
		.removeClass('loading')
		.css({width: 250, height: height});
	    
	    thumbnail(image, 250, 1, this);
	    this.loaded && this.loaded();
	},	   
	thumbnailing: function (event) {
	    this.bar.width(((event.loaded / event.total) * 100) + '%');
	},
	thumbnailed: function (data) {
	    this.image.source(data);
	    this.element.addClass('loaded').removeClass('thumbnailing');
	}
    }, view = {	      
	show: function () {

	}
    }, configuration = {
	thumbnailer: {
	    thumbnailing: handlers.thumbnailing, 
	    thumbnailed: handlers.thumbnailed,
	}
    }, thumbnail = thumbnailer(configuration.thumbnailer);

    return that;
})();