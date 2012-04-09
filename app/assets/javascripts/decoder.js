//=require jpg
//=require png
   
var decoder = (function () {
    var decodable = {
	'image/jpeg': true,
	'image/png': true
    }		     

    return {
	// TODO Discover image format based on data
	format: function discover_image_format (data) {
	    
	},
	decode: function (data, format, callback) {
	    var image = undefined;	
	    
	    switch (format || decoder.format(data)) {
	    case 'image/jpeg':
		image = new JpegImage();
		image.parse(new Uint8Array(data));
		callback.call(this, image);
		break;	      
	    default:
		return false;
	    }		 
	},	    	    	   
	decodable: function (mime) {
	    return !!decodable[mime];						 
	}	     
    };

})();