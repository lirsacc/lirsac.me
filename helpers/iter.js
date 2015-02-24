"use strict";

module.exports.name = "iter";

module.exports.fn = function iter (context, opts) {

  var hash = opts.hash;
  var options = arguments[arguments.length - 1];
  var ret = '';

  if (context && context.length > 0) {

    var limit = context.length;
    if (hash.limit && parseInt(hash.limit) !== NaN) {
        limit = Math.min(limit, parseInt(hash.limit));
    }

    if (hash.reverse) {
      for (var i = context.length - 1; i >= context.length - limit; i--) {
        ret += options.fn(context[i]);
      }
    } else {
      for (var i = 0; i < limit; i++) {
        ret += options.fn(context[i]);
      }
    }

  } else {
    ret = options.inverse(this);
  }

  return ret;
};
