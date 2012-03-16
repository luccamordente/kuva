var uploader = (function declare_uploader () {
    var that = function initialize (selector, settings) {
	if (!selector && instance) return instance;
	instance = $(selector);
	instance.settings = settings;
	$.extend(instance, uploader);
    },			    
    configuration = {
		    		     
    };
    
    var uploader = {
	upload: function upload_file(file) {
	    if ($.type(file) == 'array') {
		for (index in file) {
		    this.upload(file[index]);
		}		     
	    } else {
		transport.add(file);
	    }		  
	}
    }	

    var transport = {
	queue: {},
	add: function (file) {
	    this.queue[file.name] = file;
	}
    }	
	
    
    return that;
}).call(lib)