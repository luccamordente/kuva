//=require dropfile
if (typeof Object.create !== "function") {
    Object.create = (function () {
	function F() {} // created only once
	return function (o) {
	    F.prototype = o; // reused on each invocation
	    return new F();
	};
    })();
}

inherit = Object.create;			      