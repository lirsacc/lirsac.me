"use strict";

var _ = require('lodash');

var utils = require('./utils');

var NAME = 'image';

module.exports.name = NAME;
module.exports.template = true;

module.exports.fn = utils.makeTemplateHelper(
	NAME,
	function imageHelper(src, opts) {

		opts = opts.hash;

		if (!src) {
			throw new Error('Image Helper needs at least a source url');
		}

		var classes = [],
			attributes = {},
			context = {};

		classes.push(opts.size || 'big');

		attributes['src-retina'] = opts.retina || src;
		if (opts.noZoom) {
			context.noZoom = true;
			classes.push('no-zoom');
		} else {
			attributes['zoom'] = opts.zoom || attributes['src-retina'];
			attributes['zoom-retina'] = opts.zoomRetina || attributes['zoom'];
		}

		if (opts.noLazy) {
			context.noLazy = true;
			classes.push('no-lazy');
		} else {
			attributes['lazy'] = undefined;
		}

		context = _.extend(context, {
			classes: classes.join(' '),
			attributes: utils.parseAttributes(attributes),
			src: src
		});

		return context;
	});
