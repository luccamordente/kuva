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
	    index = -1;	      

	    instance.files = [];

	    instance.add = function (files) {
		for (var i = 0, j = files.length; i < j; i++) {
		    this.files.push(files[i]);
		}
		return this;
	    }		   
	    	       
	    instance.read = function (files) {
		if (files) instance.add(files);
		if (!ended()) next.call(instance);
	    }
	    instance.next = instance.read;

	    function next () { 
		this.file = this.files[++index];
		return this.readAsDataURL(this.file);
	    }

	    function ended () {
		return (instance.files.length - 1) == index;
	    }					 
	    
	    instance.index = function () {
		return index;
	    };
	    
	    return that;
	})();	     		  
	
    } else {
	// var file = inherit({
	    
	// });
    }
    
    this.reader = reader;
    return reader;
}).call(lib);