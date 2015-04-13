var basename = require('path').basename;
var dirname = require('path').dirname;
var extname = require('path').extname;

/**
 * Expose `plugin`.
 */

module.exports = plugin;

function plugin (options) {

  options = options || {};

  var keys = options.keys || [];

  var md = require('markdown-it')('default', options.markdown || {
    html: true,
    linkify: true,
    typographer: true
  });

  // Extensions need to be valid npm modules
  (options.extensions || []).forEach( function (extension) {
    md.use(require(extensionModule(extension)));
  });

  return function (files, metalsmith, done) {

    setImmediate(done);

    Object.keys(files).forEach( function (file) {

      if (!markdown(file)) return;

      var data = files[file];
      var dir = dirname(file);
      var html = basename(file, extname(file)) + '.html';
      if ('.' != dir) html = dir + '/' + html;

      var str = md.render(data.contents.toString());
      data.contents = new Buffer(str);
      keys.forEach(function(key) {
        data[key] = md.render(data[key]);
      });

      delete files[file];
      files[html] = data;
    });
  };
}

function markdown(file){
  return /\.md|\.markdown/.test(extname(file));
}

function extensionModule (extension) {
  if (extension.indexOf('markdown-it-') === 0) {
    return extension;
  } else {
    return 'markdown-it-' + extension;
  }
}
