//= require /library/framework/bus

var uploader = (function declare_uploader (reader) {
	var that = function initialize (selector, settings) {
		if (!settings) {
			settings = selector
			selector = null
		}

		settings = $.extend(defaults, settings)

		if (selector) instance = $(selector)
		else instance = {}


		// TODO remover split e colocar array
		$('progress finish error abort'.split(' ')).each(function (index, value) {
			settings[value] && (uploader[value + 'ed'] = settings[value]);
		});

		return $.extend(instance, settings, uploader);
	},
	defaults = {
		url: '/images'
	};

	var uploader = {
		// TODO Check if file is array and upload multiple files
		upload: function upload_file(files) {
			this.get && this.get(0).files && (files = this.get(0).files);		// jQuery compatibility
			files.length || (files = $.makeArray(files));						// Transform any paremeter in array

			if (files.length) {

				for (var i = 0, j = files.length; i < j; i++) {
					this.enqueue(files[i]);
				}

				this.next();
			}
		},
		queue: [],
		status: 'idle',
		enqueue: function (file) {
			this.queue.push(file);
		},
		next: function () {
			if (this.status === 'idle') {
				this.status = 'sending';
				console.log('internal data is', this.data)
				$.ajax({
					type: 'post',
					dataType: 'file_reference',
					data: this.data,
					url: this.url,
					success: this.success,
					context: this
				});
			}
		},
		success: function (response) {
			this.status = 'idle';
			// TODO In response remove especific uploaded files
			this.queue.splice(0, response.amount);
			this.queue.length && uploader.next();
		}
	};

	var transport = {
		flash: function ( settings, original, xhr ) {
			if ( settings.type === "POST" ) {
				return {
					send: function ( headers, completeCallback ) {
						console.log('settings are', settings)
						settings.data = '&' + settings.data;
						var event = {
							controller: 'images',
							action: 'send',
							destination: 'flash',
							type: 'request',
							headers: headers,
							url: settings.url,
							settings: settings
						}, type;

						event.key = bus.key(event);
						if (settings.success)
							type = event.controller + '.' + event.action + '(' + event.key + ')'
     						bus.listen(type + '.success',
									   function request_succeeded (data) {
										   data.response && (data.response.original_event = event)
										   settings.success.call(settings.context || window, data.response);
										   bus.mute(type + '.success');
									   }
									  );
						bus.publish(event);

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