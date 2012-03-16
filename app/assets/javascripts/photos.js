var photos = (function declare_photos () {
    var that = function initialize_photo(options) {
	
    }, reader = lib.reader();
    
    reader.onprogress = function() {
	console.log(".");
    };

    reader.onabort = function(event) {
	console.log(event);
	// console.log(reader.file.name + " cancelado!");
    };

    reader.onloadstart = function(e) {
	console.log("start")
    };

    reader.onload = function (event) {
	var file = event.target.file;
	if(file.type.match("image.*"))
	    show({
		src: event.target.result,
		name: file.name
	    });		   
	
	console.log(file.name + " loaded!!");
    };

    reader.onloadend = function() {
	setTimeout(function () {
	    reader.next();
	}, 500);
    };		   

    function change (event) {
	reader.read(this.files);
    }	    		    
    
    function abort () {
	reader.abort();
    }	

    function show (options) {
	$("#list").jqoteapp("#image-template",{
	    src: options.src,
	    name: options.name
	}, '*');
    };
    
    function initialize() {
	$('#files').bind('change', change);
	$('#abort').bind('click', abort);
	$.jqotetag('*');
	uploader('#files', {thumbnailer: reader});
    }		     			 

    $(initialize);
      
    return that;
})();