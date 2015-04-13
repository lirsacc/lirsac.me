"use strict";

var Handlebars = require('handlebars');

module.exports = {};

module.exports.parseAttributes = function parseAttributes(attrs) {
	var parsed = "";
	for (var key in attrs) {
		parsed += 'data-' + key;
		if (attrs[key]) {
      parsed += '="' + attrs[key] + '"';
    }
		parsed += " ";
	}
	return parsed.trim();
};

module.exports.makeTemplateHelper = function makeTemplateHelper(name, fn) {

	return function() {

		var partial = Handlebars.partials['@' + name];
		if (!partial) {
			throw new Error('Couldn\'t find partial with name @' + name);
    }

		var context = fn.apply(this, arguments),
			tmpl = Handlebars.compile(partial.toString());

		return tmpl(context);
	};

};
