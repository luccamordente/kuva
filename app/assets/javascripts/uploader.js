var uploader = (function declare_uploader (reader) {
    var that = function initialize (selector, settings) {
	settings = settings || {};
	if (!selector && instance) return instance;
	instance = $(selector);

	// TODO remover split e colocar array
	$('progress finish error abort'.split(' ')).each(function (index, value) {
	    settings[value] && (transport[value + 'ed'] = settings[value]);
	});

	transport.uploader = settings.uploader;

	instance.settings = settings;
	return $.extend(instance, uploader);
    },
    configuration = {

    }, instance;

    var uploader = {
	upload: function upload_file(file) {
	    file = file || this.get(0).files;

	    if (file.constructor == FileList) {

		for (var i = 0, j = file.length; i < j; i++) {
		    transport.enqueue(file[i]);
		}

		transport.next();
	    } else {
		transport.enqueue(file).next();
	    }
	}
    };

    var transport = {
	sending: false,
	queue: [],
	enqueue: function (file) {
	    this.queue.push(file);
	    return this;
	},
	next: function () {
	    if (this.sending || !this.queue.length) return this;
	    this.send(this.queue.shift());
	    return this;
	},
	sended: function () {
	    transport.sending = false;
	    transport.next();
	},
	send: function (file) {
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

    return that;
}).call(lib, reader);