"use strict";

var Lazy = {},
    $ = require('./helpers.js');

var _opts = {
  tolerance: 200,
  retina: true,
  debounceRate: 150,
  selector: 'data-src',
  debug: false,
  cb: undefined
};

var _scrollHandler = null;

function _inView (elem) {
  var width = window.innerWidth || document.documentElement.clientWidth,
    height = window.innerHeight || document.documentElement.clientHeight,
    bounds = elem.getBoundingClientRect();
  return (
    bounds.top >= 0 &&
    bounds.top <= height + _opts.tolerance &&
    bounds.left >= 0 &&
    bounds.left <= width + _opts.tolerance &&
    bounds.right >= -_opts.tolerance &&
    bounds.bottom >= -_opts.tolerance);
};

function _show (elem) {

  var tmpImage = new Image(),
    newSrc;

  if (_opts.debug) {
    console.log("[Lazy::show] " + (elem.getAttribute(_opts.selector)), elem);
  }

  if (_opts.retina && elem.hasAttribute(_opts.selector + "-retina")) {
    newSrc = elem.getAttribute(_opts.selector + "-retina");
  } else {
    newSrc = elem.getAttribute(_opts.selector);
  }

  tmpImage.src = newSrc;

  return tmpImage.onload = function () {
    elem.src = tmpImage.src;
    $.addClass(elem, "loaded");
    elem.removeAttribute(_opts.selector);
    var spinner = elem.parentNode.querySelector(".spinner");
    if (spinner != null) {
      return elem.parentNode.removeChild(spinner);
    }
  };
};

function _getTargets () {
  return document.querySelectorAll("img[" + _opts.selector + "]");
};

function _addSpinner (elem) {
  var spinner = document.createElement("div");
  $.addClass(spinner, "spinner");
  elem.parentNode.appendChild(spinner)
}

Lazy.load = function () {
  var targets = _getTargets();

  if (targets.length == 0) {
    return Lazy.cancel();
  }

  [].forEach.call(targets, function (elem) {
    if (_inView(elem)) {
      _show(elem);
    }
  });
};

Lazy.cancel = function () {
  $.removeEvent(window, 'scroll', _scrollHandler);
  $.removeEvent(window, 'resize', _scrollHandler);
  $.removeEvent(window, 'orientationchange', _scrollHandler);
};

Lazy.init = function (opts) {

  for (var key in opts) {
    _opts[key] = opts[key];
  }
  _opts.retina = _opts.retina && window.devicePixelRatio > 1;

  [].forEach.call(_getTargets(), _addSpinner);

  Lazy.load();

  if (!!_opts.debounceRate) {
    _scrollHandler = $.debounce(Lazy.load, _opts.debounceRate);
  } else {
    _scrollHandler = Lazy.load;
  }

  $.addEvent(window, "scroll", _scrollHandler);
  $.addEvent(window, "resize", _scrollHandler);
  $.addEvent(window, "orientationchange", _scrollHandler);
};

module.exports = Lazy;
