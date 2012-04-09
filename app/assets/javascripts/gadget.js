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
	    this.element.css({width: 250, height: 250}).fadeIn();
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
		source: 'http://' + kuva.service.url + '/assets/blank.gif',
		title: 'Sumonando imagem'
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
	},
	loadend: function reader_loadend (event) {
	    // TODO better way of cheking if readfile has ended
	    if (event.loaded == event.total) {
		resizer.context = this;
		resizer.type = event.target.file.type;
		resizer.on('load', $.proxy(handlers.loaded, this))
		    .source(event.target.result, true);
	    } else {						 

	    }
	},
	loaded: function image_loaded (event) {
	    var thumb = {width: 250, height: 250 / resizer.ratio()}

	    this.element.addClass('thumbnailing')
		.removeClass('loading')
		.css(thumb);
	    
	    resizer.resize(250, null, 1, this);

	    this.bar.updated = (new Date()).getTime();
	    this.loaded && this.loaded();
	},	   
	thumbnailing: function thumbnailer_thumbnailing (event) {
	    var percentage = ((event.loaded / event.total) * 100), now = (new Date()).getTime();

	    if (now - this.bar.updated > 200) {
		this.bar.clearQueue().animate({width: percentage + '%'}, 1000, 'linear');
		this.bar.updated = now;
	    }
	},
	thumbnailed: function thumbnailer_thumbnailed (data) {
	    var gadget = this;


	    this.bar.animate({width: '100%'}, 1000, 'linear', function () {
		gadget.image.hide();

		// TODO Fix in a better way the hide bug on webkit browsers
		setTimeout(function () {		    	   
		    gadget.element.addClass('loaded').removeClass('thumbnailing');
		    gadget.image.source(data).show('slow', function () {
			gadget.bar.hide();
		    }, 1)
		});

		gadget.thumbnailed && gadget.thumbnailed();
	    });
	}
    }, view = {	      
	show: function () {

	}
    }, configuration = {
	resizer: {
	    thumbnailing: handlers.thumbnailing, 
	    thumbnailed: handlers.thumbnailed,
	}
    }, resizer = image(null, configuration.resizer);

    return that;
})();