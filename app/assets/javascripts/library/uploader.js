//= require /library/framework/bus

var uploader = (function declare_uploader (reader) {
	var that = function initialize (selector, settings) {
		settings = $.extend({url: 'images'}, settings)
		if (!selector && instance) return instance;
		instance = $(selector);

		// TODO remover split e colocar array
		$('progress finish error abort'.split(' ')).each(function (index, value) {
			settings[value] && (uploader[value + 'ed'] = settings[value]);
		});

		return $.extend(instance, settings, uploader);
	},
	configuration = {

	}, instance;

	var uploader = {
		// TODO Check if file is array and upload multiple files
		upload: function upload_file(file) {
			file = file || this.get(0).files;

			if (file.constructor == FileList) {

				for (var i = 0, j = file.length; i < j; i++) {
					this.enqueue(file[i]);
				}

				this.next();
			} else {
				this.enqueue(file).next();
			}
		},
		queue: [],
		status: 'idle',
		enqueue: function (file) {
			this.queue.push(file);
		},
		next: function () {
			if (this.status === 'idle') {
				$.ajax({
					type: 'post',
					dataType: 'file_reference',
					data: this.data,
					url: this.url
				});
			}
		}
	};

	var transport = {
		flash: function ( settings, original, xhr ) {
			if ( settings.type === "POST" ) {
				return {
					send: function ( headers, completeCallback ) {
						bus.publish({
							controller: 'images',
							action: 'send',
							destination: 'flash',
							type: 'request',
							headers: headers,
							url: settings.url,
							settings: settings
						});
					},
					abort: function() {
						/* abort code */
					}
				};
			}

		},
		// TODO if and when browser supports xhr upload property and form data
		// use it
		native: function (file) {
			this.sending = true;

			var xhr = new XMLHttpRequest(), data = new FormData();

			xhr.upload.addEventListener('progress', this.progressed, false);
			xhr.addEventListener('load', this.finished, false);
			xhr.addEventListener('load', this.sended, false);
			xhr.addEventListener('error', this.errored, false);
			xhr.addEventListener('abort', this.aborted, false);
			xhr.open('POST', this.uploader);

			// xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
			// xhr.setRequestHeader("Cache-Control", "no-cache");
			// xhr.setRequestHeader("X-File-Name", file.name);

			data.append("image", file);
			//console.log('posting', file);
			xhr.send(data);
		}
	};

	// Activate transports
	$.ajaxTransport("file_reference", transport.flash);

	return that;
}).call(library, window.reader = window.reader || {});