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
				if (files) this.add(files);
				if (!ended() && this.readyState !== this.LOADING) next.call(instance);
			}					 	  
			instance.next = instance.read;

			instance.read.as = function (mode) {
				var method = 'readAs' + mode[0].toUpperCase() + mode.substring(1);
				if (!instance[method]) throw 'reader.read.as: Invalid read mode: ' + mode
				this.method = method;
				return instance;	      	     		      	   	     
			}	    	   
			instance.read.method = 'readAsText';
 		  	
			function next () {
				if (this.readyState !== this.LOADING) {
					this.file = this.files[++index];
					// TODO Fill prepare event
					this.onprepare && this.onprepare.call(this, {});
					console.log('nexted');
					return this[this.read.method](this.file);
				} else {
					return true;
				}
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