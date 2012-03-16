lib = {};
var reader = (function() {
    var that = function () {
	
    }

    if (Modernizr.filereader) {
	var reader = (function () {
	    var that = function () {
		return instance;
	    },	       
	    instance = new FileReader(),
	    index = 0;	      

	    instance.files = [];

	    instance.add = function (files) {
		for (var i = 0, j = files.length; i < j; i++) {
		    this.files.push(files[i]);
		}
		return this;
	    }		   
	    	       
	    instance.next = function () {
		this.file = this.files[index++];
		return this.readAsDataURL(this.file);
	    }

	    instance.read = function (files) {
		if (files) {    
		    instance.add(files);
		    if (!runned() || ended()) instance.next();
		}
	    }

	    function ended () {
		return instance.files.length == index;
	    }			
	    
	    function runned() {
		return index != 0;
	    }		
	    
	    
	    return that;
	})();	     		  
	
    } else {
	// var file = inherit({
	    
	// });
    }
    
    this.reader = reader;
    return reader;
}).call(lib);