//= require library/image

var gadget = (function declare_gadget () {

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
			return this;
		},
		dispatch: function (name, event) {
			handlers[name] && handlers[name].call(this, event);
			return this;
		},
		listen: function (name, callback) {
			this[name] = callback;
			return this;
		}
    }, control = {
		create: function () {
			this.data = $.extend({
				id: id++,
				source: kuva.service.url + '/assets/blank.gif',
				title: 'Sumonando imagem'
			}, this.data);

			$(this.parent).jqoteapp(template, this.data);
			this.element = $('#gadget-' + this.data.id);
			this.image = library.image(this.element.find('img'), this.data.title);
			this.upload_bar = this.element.find('.upload.bar');
			this.thumbnail_bar = this.element.find('.thumbnail.bar');
		}
    },
    handlers = {
		loadstart: function reader_loadstart (event) {
			this.element.addClass('reading');
		},
		loadend: function reader_loadend (event) {
			var scale = Math.min(250 / event.width, 250 / event.height),
			width = scale * event.width, height = scale * event.height;

			this.element.removeClass('reading').addClass('thumbnailing');
			this.element.css({width: width, height: height});
			this.image.title(event.file.name);
			this.thumbnail_bar.updated = (new Date()).getTime();
		},
		thumbnailing: function thumbnailer_thumbnailing (event) {
			var percentage = ((event.parsed / event.total) * 100), now = (new Date()).getTime();

			if (now - this.thumbnail_bar.updated > 200) {
				this.thumbnail_bar.stop().animate({width: percentage + '%'}, 1000, 'linear');
				this.thumbnail_bar.updated = now;
			}
		},
		encoding: function thumbnailer_encoding (event) {
			this.thumbnail_bar.animate({width: '100%'});
		},
		thumbnailed: function thumbnailer_thumbnailed (event) {
			var gadget = this;

			this.thumbnail_bar.animate({width: '100%'}, 1000, 'linear', function () {
				gadget.image.hide();

				// TODO Fix in a better way the hide bug on webkit browsers
				setTimeout(function () {
					var prefix = "data:image/jpg;base64,";

					gadget.element.addClass('loaded').removeClass('thumbnailing');
					gadget.image.source(prefix + event.base64).show('slow', function () {
						gadget.thumbnail_bar.hide();
					}, 1)
				});

				// TODO resizer.unload();
				gadget.thumbnailed && gadget.thumbnailed();		// Execute callback if any
			});

		},
		upload: function upload_start (event) {
			this.element.addClass('uploading');
			this.upload_bar.show().width("0%");
		},
		uploading: function upload_progress (event) {
			var percentage = ((event.loaded / event.total) * 100);

			this.upload_bar.stop().animate({width: percentage + '%'}, 1000, 'linear');
		},
		uploaded: function upload_complete(event) {
			var gadget = this;

			this.upload_bar.animate({width: '100%'}, 1000, 'linear', function () {
				gadget.upload_bar.fadeOut(function () {
					gadget.element.removeClass('uploading').addClass('uploaded');
				});
			});
		}
    }, view = {
		show: function () {
		}
    }; /*, TODO configuration = {
		 resizer: {
	     thumbnailing: handlers.thumbnailing,
	     thumbnailed: handlers.thumbnailed,
		 }
		 }, resizer = image(null, configuration.resizer); */

	var template = null;

	function initialize() {
		template = $.jqotec('#gadget');
	}

	$(initialize)

    return that;
})();