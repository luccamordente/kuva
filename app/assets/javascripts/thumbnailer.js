var thumbnailer = (function () {
    var that = function () {
	return that;
    }, canvas = document.createElement('canvas');
    
    /** TODO implemente thumbnailing queue */
    that.thumbnail = function (image, width, callback, quality) {
	quality = quality || 5;
	new thumbnailer(canvas, image.element || image, width, quality, callback);
    };		    

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
    function thumbnailer(canvas, image, width, lobes, callback) { 
	this.canvas = canvas;
	this.thumbnailed = callback;

	canvas.style.display = 'none';
	canvas.width = image.width;
	canvas.height = image.height;

	this.context = canvas.getContext("2d");
	this.context.drawImage(image, 0, 0);
	this.image = image;
	this.src = this.context.getImageData(0, 0, image.width, image.height);
	this.dest = {
            width: width,
            height: Math.round(image.height * width / image.width),
	};

	this.dest.data = new Array(this.dest.width * this.dest.height * 3);
	this.lanczos = lanczos(lobes);
	this.ratio = image.width / width;
	this.rcp_ratio = 2 / this.ratio;
	this.range = Math.ceil(this.ratio * lobes / 2);
	this.cache = {};
	this.center = {};
	this.icenter = {};
	
	setTimeout(this.process1, 0, this, 0);
    }

    thumbnailer.prototype.process1 = function(self, u){
        var a, r, g, b, v, i, j, idx;

	self.center.x = (u + 0.5) * self.ratio;
	self.icenter.x = Math.floor(self.center.x);

	for (v = 0; v < self.dest.height; v++) {
            self.center.y = (v + 0.5) * self.ratio;
            self.icenter.y = Math.floor(self.center.y);
            a = r = g = b = 0;

            for (i = self.icenter.x - self.range; i <= self.icenter.x + self.range; i++) {
		if (i < 0 || i >= self.src.width) 
                    continue;
		var f_x = Math.floor(1000 * Math.abs(i - self.center.x));
		if (!self.cache[f_x]) 
                    self.cache[f_x] = {};
		for (j = self.icenter.y - self.range; j <= self.icenter.y + self.range; j++) {
                    if (j < 0 || j >= self.src.height) 
			continue;
                    var f_y = Math.floor(1000 * Math.abs(j - self.center.y));
                    if (self.cache[f_x][f_y] == undefined) 
			self.cache[f_x][f_y] = self.lanczos(Math.sqrt(Math.pow(f_x * self.rcp_ratio, 2) + Math.pow(f_y * self.rcp_ratio, 2)) / 1000);
                    weight = self.cache[f_x][f_y];
                    if (weight > 0) {
			idx = (j * self.src.width + i) * 4;
			a += weight;
			r += weight * self.src.data[idx];
			g += weight * self.src.data[idx + 1];
			b += weight * self.src.data[idx + 2];
                    }
		}
            }

            idx = (v * self.dest.width + u) * 3;
            self.dest.data[idx] = r / a;
            self.dest.data[idx + 1] = g / a;
            self.dest.data[idx + 2] = b / a;
	}

	if (++u < self.dest.width) 
            setTimeout(self.process1, 0, self, u);
	else 
            setTimeout(self.process2, 0, self);
    };
    

    thumbnailer.prototype.process2 = function(self) {
	self.canvas.width = self.dest.width;
	self.canvas.height = self.dest.height;
	self.context.drawImage(self.image, 0, 0);
	self.src = self.context.getImageData(0, 0, self.dest.width, self.dest.height);
	var idx, idx2;
	for (var i = 0; i < self.dest.width; i++) {
            for (var j = 0; j < self.dest.height; j++) {
		idx = (j * self.dest.width + i) * 3;
		idx2 = (j * self.dest.width + i) * 4;
		self.src.data[idx2] = self.dest.data[idx];
		self.src.data[idx2 + 1] = self.dest.data[idx + 1];
		self.src.data[idx2 + 2] = self.dest.data[idx + 2];
            }
	}
	self.context.putImageData(self.src, 0, 0);
	self.thumbnailed(self.canvas.toDataURL());
    }			      

    // Returns a function that calculates lanczos weight
    function lanczos(lobes){
	return function(x){
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