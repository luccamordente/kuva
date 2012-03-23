var thumbnailer = (function () {
    var that = function (handlers) {
	handlers && $.extend(instance, handlers);
	return instance;
    },
    instance = function () {
	queue.push(arguments);
	queue.process();
    };

    $.extend(instance, {	      
	canvas: document.createElement('canvas'),
	sample: null,
    });

    /** TODO implemente thumbnailing queue */
    function thumbnail (image, width, quality, context) {
	quality = quality || instance.quality || 5;

	instance.callback_context = context || instance;
	instance.sample = 0;
	instance.canvas.height = image.height;
	instance.canvas.width = image.width;
	initialize(image.element || image, width, quality);
    };


    var queue = {
	processor: thumbnail,
	processing: false,
	process: function () {
	    if (this.processing) return;
	    else this.processing = true;

	    var event = this.shift();
	    this.processor.apply(event.callee, event); 
	},
	processed: function () {
	    this.processing = false;
	    this.length && this.process();
	},	 		
	shift: Array.prototype.shift,
	push: Array.prototype.push
    }	     	    

    /**
     * @author http://stackoverflow.com/users/219229/syockit   
     * @author http://aggen.sourceforge.net/				  
     * @author Heitor Salazar
     *
     * @param canvas: canvas element
     * @param image: image element
     * @param width: scaled width
     * @param lobes: kernel radius (quality)
     * @param callback: callback to call when finished processing image
     */	
    function initialize(image, width, lobes) { 
	instance.context = instance.canvas.getContext("2d");
	instance.context.drawImage(image, 0, 0);
	instance.image = image;
	instance.src = instance.context.getImageData(0, 0, image.width, image.height);
	instance.dest = {
	    width: width,
	    height: Math.round(image.height * width / image.width),
	};

	instance.dest.data = new Array(instance.dest.width * instance.dest.height * 3);
	instance.lanczos = lanczos(lobes);
	instance.ratio = image.width / width;
	instance.rcp_ratio = 2 / instance.ratio;
	instance.range = Math.ceil(instance.ratio * lobes / 2);
	instance.cache = {};
 	instance.center = {};
	instance.icenter = {};
	
	// TODO
	// var worker = new Worker('assets/process.js');
	// worker.postMessage({context: domo});
	// worker.onmessage = function (event) {
	// 	var data = event.data;
	// 	instance.finish(data.self);
	// }
	
	setTimeout(process, 10);
    };

    function process(u) {
        var a, r, g, b, v, i, j, idx;

	u = u || 0;

	instance.center.x = (u + 0.5) * instance.ratio;
	instance.icenter.x = Math.floor(instance.center.x);

	for (v = 0; v < instance.dest.height; v++) {
	    instance.center.y = (v + 0.5) * instance.ratio;
	    instance.icenter.y = Math.floor(instance.center.y);
	    a = r = g = b = 0;

	    for (i = instance.icenter.x - instance.range; i <= instance.icenter.x + instance.range; i++) {
		if (i < 0 || i >= instance.src.width) 
		    continue;
		var f_x = Math.floor(1000 * Math.abs(i - instance.center.x));
		if (!instance.cache[f_x]) 
		    instance.cache[f_x] = {};
		for (j = instance.icenter.y - instance.range; j <= instance.icenter.y + instance.range; j++) {
		    if (j < 0 || j >= instance.src.height) 
			continue;
		    var f_y = Math.floor(1000 * Math.abs(j - instance.center.y));
		    if (instance.cache[f_x][f_y] == undefined) 
			instance.cache[f_x][f_y] = instance.lanczos(Math.sqrt(Math.pow(f_x * instance.rcp_ratio, 2) + Math.pow(f_y * instance.rcp_ratio, 2)) / 1000);
		    weight = instance.cache[f_x][f_y];
		    if (weight > 0) {
			idx = (j * instance.src.width + i) * 4;
			a += weight;
			r += weight * instance.src.data[idx];
			g += weight * instance.src.data[idx + 1];
			b += weight * instance.src.data[idx + 2];
		    }
		}
	    }

	    idx = (v * instance.dest.width + u) * 3;
	    instance.dest.data[idx] = r / a;
	    instance.dest.data[idx + 1] = g / a;
	    instance.dest.data[idx + 2] = b / a;
	}

	if (!(instance.sample++ % Math.round((instance.dest.width / 20))))
	    instance.thumbnailing && instance.thumbnailing.call(instance.callback_context, {target: instance.canvas, loaded: instance.sample, total: instance.dest.width});
	
	if (++u < instance.dest.width) 
	    setTimeout(process, 10, u);
	else 
	    setTimeout(finish, 0);
    }

    function finish() {
	instance.canvas.width = instance.dest.width;
	instance.canvas.height = instance.dest.height;
	instance.context.drawImage(instance.image, 0, 0);
	instance.src = instance.context.getImageData(0, 0, instance.dest.width, instance.dest.height);
	var idx, idx2;
	for (var i = 0; i < instance.dest.width; i++) {
	    for (var j = 0; j < instance.dest.height; j++) {
		idx = (j * instance.dest.width + i) * 3;
		idx2 = (j * instance.dest.width + i) * 4;
		instance.src.data[idx2] = instance.dest.data[idx];
		instance.src.data[idx2 + 1] = instance.dest.data[idx + 1];
		instance.src.data[idx2 + 2] = instance.dest.data[idx + 2];
	    }
	}
	instance.context.putImageData(instance.src, 0, 0);
	instance.thumbnailed.call(instance.callback_context, instance.canvas.toDataURL());
	queue.processed();
    }	      

    // Returns a function that calculates lanczos weight
    function lanczos(lobes) {
	return function(x) {
	    if (x > lobes) 
		return 0;
	    x *= Math.PI;
	    if (Math.abs(x) < 1e-16) 
		return 1
	    var xx = x / lobes;
	    return Math.sin(x) * Math.sin(xx) / x / xx;
	}
    }

    return that;
})();