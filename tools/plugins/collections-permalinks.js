/**
 * Simple extension to the metalsmith-collections plugin
 * Will create permalinks according to the pattern and assign collection based
 * metadata to files
 */

"use strict";

var specialAttributes = {
  "slug": function (item) {
    return item.slug || item.title;
  }
}

function _link (item, pattern) {

  var args = pattern.replace(/[\/-_\.]/, '').split(':'),
    link = pattern, val;

  args.shift();
  args.forEach(function (arg) {
    val = arg in specialAttributes ? specialAttributes[arg](item) : item[arg];
    val = val.replace(/[;,\/\?\:\@\&=\+\$]/g, '').replace(/\s+/g, '-');
    link = link.replace(':' + arg, val);
  });

  return link.toLowerCase();
}

function plugin(collections) {

	return function(files, metalsmith, done) {

		var metadata = metalsmith._metadata,
      collection, link, ext, newKey;

    for (var file in files) {
      if (files.hasOwnProperty(file)) {

        // Assume files only have on collection for now, basic usage for now
        collection = files[file].collection[0];

        if (collection && collection in collections) {

            link = _link(files[file], collections[collection].pattern);
            files[file].path = link;

            if (collections[collection].metadata) {
              var meta = collections[collection].metadata;
              Object.keys(meta).forEach(function (key) {
                files[file][key] = meta[key];
              });
            }

            ext = file.split('.').pop();
            files[link + '/index.' + ext] = files[file];
            delete files[file]
        }
      }
    }

		done();
	};
}

module.exports = plugin;
