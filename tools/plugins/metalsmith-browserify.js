"use strict";

var browserify = require('browserify'),
    path = require('path'),
    minimatch = require("minimatch");

function isScriptFile (filename) {
  return (/\.js$/i).test(filename);
}

function isBundleFile (filename, patterns) {
  return patterns.some(function (pattern) {
    return minimatch(filename, pattern, {matchBase: true});
  });
}

function plugin (opts) {

  if (!opts)
    throw new Error("You should provide at least one bundle for browserify");

  var patterns;

  if ('string' === typeof opts) {
    patterns = [opts];
  } else if (Array.isArray(opts)) {
    patterns = opts;
  } else {
    patterns = opts.patterns;
  }

  return function (files, metalsmith, done) {

    var scriptFiles = Object.keys(files).filter(isScriptFile);
    var bundleFiles = [];

    scriptFiles.map(function (file) {
      if (isBundleFile(file, patterns)) {
          bundleFiles.push(file);
      } else if (!opts.keepPartials) {
        delete files[file];
      }
    });

    var base = metalsmith.source();

    if (scriptFiles.length === 0 || bundleFiles.length === 0)
      return done();

    var count = 0;

    bundleFiles.forEach(function (file) {
      var stream = browserify(path.join(base, file)).bundle();
      var buffer = '';

      stream.on('data', function (chunk) {
          buffer += chunk;
      });

      stream.on('end', function () {
        files[file].contents = buffer;
        count++;
        if (count === bundleFiles.length)
          done();
      });

      stream.on('error', function (err) {
        throw err;
      });

    });
  }

}


module.exports = plugin;
