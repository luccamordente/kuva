var thumbnailer = (function () {
    var that = function () {
	return {thumbnail: queue.enqueue};
    },
    engine = {
	canvas: document.createElement('canvas'),
	context: null,
	sample: null,
	quality: 5,
	select: function (mixed) {
	    var parameters = Array.prototype.slice.apply(arguments), 
	    options = parameters[parameters.length - 1], those = this;
								 
	    if (mixed instanceof Image) {			     
		return engine.thumbnail.apply(this, parameters);
	    } else if (decoder.decodable(options.type || decoder.format(mixed))) {
		return decoder.decode(mixed, options.type, function (image) {	 
		    var context = engine.context,
		    data = context.createImageData(image.width, image.height);
		      	      			       
		    image.copyToImageData(data);
		    parameters[0] = data;   	     
		    
		    return engine.thumbnail.apply(those, parameters);
		});	   				  
	    } else return false;	     
	},
	thumbnail: function thumbnail (image, width, quality) {
	    quality = quality || engine.quality || 5;
	    
	    // TODO Change this callbacks to event listeners
	    // So engine can support multiple thumbnailigns at the same time
	    engine.thumbnailing = this.thumbnailing;
	    engine.thumbnailed = this.thumbnailed;
	    engine.instance = this;
	    
	    engine.sample = 0;
	    engine.canvas.height = image.height;
	    engine.canvas.width = image.width;
	    
	    engine.warm(image.element || image, width, quality);
	},	    
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
	warm: function warm(image, width, lobes) { 
	    var context = engine.context;

	    engine.image = image;

	    if (image instanceof Image) {
		context.drawImage(image, 0, 0);
		engine.src = context.getImageData(0, 0, image.width, image.height);
	    } else if (image instanceof ImageData) {
		engine.src = image;
	    }	       	     

	    engine.dest = {
		width: width,
		height: Math.round(image.height * width / image.width),
	    };

	    engine.dest.data = new Array(engine.dest.width * engine.dest.height * 3);
	    engine.lanczos = lanczos(lobes);
	    engine.ratio = image.width / width;
	    engine.rcp_ratio = 2 / engine.ratio;
	    engine.range = Math.ceil(engine.ratio * lobes / 2);
	    engine.cache = {};
 	    engine.center = {};
	    engine.icenter = {};
	    
	    // TODO Multhread thumbnailing
	    // var worker = new Worker('assets/process.js');
	    // worker.postMessage({context: domo});
	    // worker.onmessage = function (event) {
	    // 	var data = event.data;
	    // 	engine.finish(data.self);
	    // }
	    
	    setTimeout(engine.move, 10);
	},
	move: function process(u) {
            var a, r, g, b, v, i, j, idx, f_x = undefined, f_y = undefined;

	    u = u || 0;

	    engine.center.x = (u + 0.5) * engine.ratio;
	    engine.icenter.x = Math.floor(engine.center.x);

	    for (v = 0; v < engine.dest.height; v++) {
		engine.center.y = (v + 0.5) * engine.ratio;
		engine.icenter.y = Math.floor(engine.center.y);
		a = r = g = b = 0;

		for (i = engine.icenter.x - engine.range; i <= engine.icenter.x + engine.range; i++) {
		    if (i < 0 || i >= engine.src.width) continue;

		    f_x = Math.floor(1000 * Math.abs(i - engine.center.x));

		    if (!engine.cache[f_x]) 
			engine.cache[f_x] = {};

		    for (j = engine.icenter.y - engine.range; j <= engine.icenter.y + engine.range; j++) {
			if (j < 0 || j >= engine.src.height) continue;

			f_y = Math.floor(1000 * Math.abs(j - engine.center.y));
			if (engine.cache[f_x][f_y] == undefined) 
			    engine.cache[f_x][f_y] = engine.lanczos(Math.sqrt(Math.pow(f_x * engine.rcp_ratio, 2) + Math.pow(f_y * engine.rcp_ratio, 2)) / 1000);

			weight = engine.cache[f_x][f_y];

			if (weight > 0) {
			    idx = (j * engine.src.width + i) * 4;
			    a += weight;
			    r += weight * engine.src.data[idx];
			    g += weight * engine.src.data[idx + 1];
			    b += weight * engine.src.data[idx + 2];
			}
		    }
		}

		idx = (v * engine.dest.width + u) * 3;
		engine.dest.data[idx] = r / a;
		engine.dest.data[idx + 1] = g / a;
		engine.dest.data[idx + 2] = b / a;
	    }

	    if (!(engine.sample++ % Math.round((engine.dest.width / 20))))
		engine.thumbnailing && engine.thumbnailing.call(engine.instance.context || engine.instance, {target: engine.canvas, loaded: engine.sample, total: engine.dest.width});
	    
	    if (++u < engine.dest.width) setTimeout(engine.move, 10, u);
	    else setTimeout(engine.stop, 0);
	},
	stop: function finish() {
	    var canvas = engine.canvas, context = engine.context, 
	    source = null, 
	    resized = engine.dest,
	    idx = undefined,
	    idx2 = undefined,
	    i = 0
	    j = 0;
		   
	    canvas.width = resized.width;
	    canvas.height = resized.height;

	    if (engine.image instanceof Image) {
		context.drawImage(engine.image, 0, 0);
	    } else if (engine.image instanceof ImageData) {
		context.putImageData(engine.image, 0, 0);
	    }
	    
	    source = context.getImageData(0, 0, resized.width, resized.height);

	    for (i = 0; i < resized.width; i++) {
		for (j = 0; j < resized.height; j++) {
		    idx = (j * resized.width + i) * 3;
		    idx2 = (j * resized.width + i) * 4;
		    source.data[idx2] = resized.data[idx];
		    source.data[idx2 + 1] = resized.data[idx + 1];
		    source.data[idx2 + 2] = resized.data[idx + 2];
		}
	    }

	    context.putImageData(source, 0, 0);

	    // TODO clear canvas data
	    engine.clear();
	    engine.thumbnailed.call(engine.instance.context || engine.instance, canvas.toDataURL());
	    queue.processed();
	},
	clear: function clear_memory() {
	    delete engine.dest;	  
	    delete engine.context;
	    delete engine.instance;
	    delete engine.ratio;
	    delete engine.src;
	    delete engine.cache;
	}   		       
    }, 
    queue = {	
	processor: engine.select,
	processing: false,
	process: function () {
	    var event = undefined;
	    if (this.processing) return;
	    else this.processing = true;

	    event = this.shift();
	    console.profile("engine");
	    console.log(console.memory);
	    this.processor.apply(this.shift.apply(event), event); 
	    console.log(console.memory);
	    console.profileEnd();
	},
	processed: function () {
	    this.processing = false;
	    this.length && this.process();
	},	 		
	enqueue: function enqueue () {
	    Array.prototype.unshift.call(arguments, this);
	    queue.push(arguments);
	    queue.process();
	},
	shift: Array.prototype.shift,
	push: Array.prototype.push
    };		   

    
    // Returns a function that calculates lanczos weight
    function lanczos(lobes) {
	return function(x) {
	    var xx = undefined;

	    if (x > lobes) return 0;
	    x *= Math.PI;

	    if (Math.abs(x) < 1e-16) return 1
	    xx = x / lobes;
	    return Math.sin(x) * Math.sin(xx) / x / xx;
	}
    }

    // Gears initialization
    engine.context = engine.canvas.getContext("2d");
      		     	      	    	   	  
    return that;
})();