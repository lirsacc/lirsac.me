"use strict";

var moment = require('moment');

var formats = {
	"short": "MMM DD, YYYY",
	"long": "dddd, MMMM Do YYYY"
};

module.exports.fn = function dateHelper(dateString, formatString) {
	var format;
	if (formatString in formats) {
		format = formats[formatString];
	} else {
		format = formatString;
	}
	return moment(dateString).format(format);
};

module.exports.name = "date";
