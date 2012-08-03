/* TODO
self.onmessage = function (event) {
    var data = event.data;
    process(data.context, 0)
}

function process(self, u) {   
    var a, r, g, b, v, i, j, idx;

    self.center.x = (u + 0.5) * self.ratio;
    self.icenter.x = Math.floor(self.center.x);

    for (v = 0; v < self.dest.height; v++) {
	self.center.y = (v + 0.5) * self.ratio;
	self.icenter.y = Math.floor(self.center.y);
	a = r = g = b = 0;/^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/;

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
		    self.cache[f_x][f_y] = lanczos(Math.sqrt(Math.pow(f_x * self.rcp_ratio, 2) + Math.pow(f_y * self.rcp_ratio, 2)) / 1000);
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

    // if (!(self.sample++ % Math.round((self.dest.width / 20))))
    // self.thumbnailing && self.thumbnailing.call(self.callback_context, {target: self.canvas, loaded: self.sample, total: self.dest.width});

    if (++u < self.dest.width) setTimeout(process, 1, self, u);
    else finish(self);
}		

function finish(self) {
    delete self.cache;
    postMessage({self: self, status: 'finished'});  
}


function lanczos(lobes) {
    return function(x){
	if (x > lobes) 
	    return 0;
	x *= Math.PI;
	if (Math.abs(x) < 1e-16) 
	    return 1
	var xx = x / lobes;
	return Math.sin(x) * Math.sin(xx) / x / xx;
    }
}*/