"use strict";

module.exports.name = "is";

var comparisons = {
	'==': function(l, r) {
		return l == r;
	},
	'===': function(l, r) {
		return l === r;
	},
	'!=': function(l, r) {
		return l != r;
	},
  '!==': function(l, r) {
    return l !== r;
  },
	'<': function(l, r) {
		return l < r;
	},
	'>': function(l, r) {
		return l > r;
	},
	'<=': function(l, r) {
		return l <= r;
	},
	'>=': function(l, r) {
		return l >= r;
	},
	'typeof': function(l, r) {
		return typeof l == r;
	}
};

module.exports.fn = function isHelper(left, right, opts) {

	if (arguments.length < 3) {
		throw new Error("'is' helper needs at least 2 arguments");
	}

	var operator = opts.op || "===";

	if (!comparisons[operator]) {
		throw new Error("Unkown operator for 'is' helper " + operator);
	}

	var result = comparisons[operator](left, right);

	return result ? opts.fn(this) : "";
};
