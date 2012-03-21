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
	}
    },
    handlers = {
	loadstart: function (event) {
	    this.show();
	    this.element.addClass('loading');
	    console.log(this.element);
	},
	loadend: function (event) {
	    console.log(event);
	    if (event.loaded == event.total) {
		var domo = this, loading = new Image();

		this.image.source('http://' + kuva.service.url + '/assets/la.gif');
		loading.src = event.target.result;
		loading.onload = function () {
		    var height = Math.round(loading.height * 200 / loading.width);
		    console.log(height);

		    domo.element.addClass('thumbnailing')
			.removeClass('loading')
			.css({width: 200, height: height});

		    thumbnailer.thumbnail(loading, 200, function (data) {
					      domo.image.source(data);
					      domo.element.addClass('loaded').removeClass('thumbnailing');
					  }, 3);
		};

	    } else {

	    }
	}
    }, view = {
	show: function () {

	}
    }

    return that;
})();