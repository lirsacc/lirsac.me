"use strict";

var _ = require('lodash');

var utils = require('./utils');

var NAME = 'quote';

module.exports.name = NAME;
module.exports.template = true;

module.exports.fn = utils.makeTemplateHelper(
	NAME,
	function quoteHelper(opts) {

		opts = opts.hash;

		return _.extend({}, {
			author: opts.author || null,
			modifier: opts.modifier ? "--" + opts.modifier : "",
			content: opts.content
		});
	});
