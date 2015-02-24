"use strict";

var $ = require('./scripts/helpers.js');
var Lazy = require('./scripts/lazy.js');

$.addEvent(document, 'DOMContentLoaded', function () {
  $.removeClass(document.body, "preload");
  Lazy.init();
});
