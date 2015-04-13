"use strict";

var Metalsmith = require('metalsmith'),
  	metadata = require('metalsmith-metadata'),
  	templates = require('metalsmith-templates'),
  	drafts = require('metalsmith-drafts'),
  	metallic = require('metalsmith-metallic'),
  	collections = require('metalsmith-collections'),
  	permalinks = require('metalsmith-permalinks'),
    sass = require('metalsmith-sass'),
    branch = require('metalsmith-branch'),
    imagemin = require('metalsmith-imagemin'),
    autoprefixer = require('metalsmith-autoprefixer'),
    feed = require('metalsmith-feed'),
    notifier = require('node-notifier'),
  	Handlebars = require('handlebars'),
  	argv = require('yargs').argv,
  	fs = require('fs'),
  	path = require('path');


var PLUGINS = path.join(__dirname, 'tools', 'plugins');

var links = require(PLUGINS + '/collections-permalinks'),
    browserify = require(PLUGINS + '/metalsmith-browserify'),
    md = require(PLUGINS + '/metalsmith-markdown-it');

var PROD = argv.production || argv.prod || argv.p || false,
  	DESTINATION = argv.output || argv.o || path.join(__dirname, '_site'),

    TEMPLATES = path.join(__dirname, 'tools', 'templates'),
  	PARTIALS = path.join(__dirname, 'tools', 'templates', 'partials'),
  	HELPERS = path.join(__dirname, 'tools', 'helpers'),
  	HELPERS_TMPL = path.join(__dirname, 'tools', 'templates', 'helpers');

// Helper functions
// ===========================================================================

function loadMetadata(dir, ext, metadata) {
	return fs.readdirSync(path.join(__dirname, 'src', dir))
		.reduce(function (data, file) {
			if (file.indexOf(ext)) {
        data[file.replace('.' + ext, '')] = path.join(dir, file);
			}
			return data;
		}, metadata || {});
}

function isTextFile (filename, props, index) {
  var ext = filename.split('.').pop().toLowerCase();
  return [ "md", "markdown", "html", "txt" ].indexOf(ext) > -1;
}

// Load Handlebars files
// ===========================================================================

(function loadPartials() {
	fs.readdirSync(PARTIALS).map(function (file) {
		Handlebars.registerPartial(
			file.replace('.hbs', ''),
			fs.readFileSync(path.join(PARTIALS, file)).toString()
		);
	});
})();

(function loadHelpers() {
	var helper;
	fs.readdirSync(HELPERS).map(function (file) {
		helper = require(path.join(HELPERS, file));
		Handlebars.registerHelper(helper.name, helper.fn);
		if (helper.template) {
			Handlebars.registerPartial(
				'@' + helper.name,
				fs.readFileSync(path.join(HELPERS_TMPL, helper.name + '.hbs'))
			);
		}
	});
})();

// Metalsmith code
// ===========================================================================

var smithy = new Metalsmith(__dirname);

// Load metadata from files
smithy.use(metadata(
	loadMetadata('data', 'yaml')
));

// Add conditionnal metadata
smithy.use(function (files, metalsmith, done) {
  metalsmith._metadata.production = PROD;
  done();
});

if (PROD)
  smithy.use(drafts());

smithy.use(collections({
	blog: {
		pattern: 'posts/*.markdown',
		sortBy: 'date',
		reverse: true
	}
}));

// Rewrite collections files
smithy.use(links({
	"blog": {
    pattern: "blog/:slug",
    metadata: {
        body_class: "blog"
    }
  }
}));

// Rewrite root level *.html to be slug/index.html
smithy.use(permalinks({
	pattern: ':slug',
	relative: false
}));

// Templates used in place for using helpers like Jekyll liquid tags
// Exclude image files as the inPlace option fails
smithy.use(branch(isTextFile).use(
  templates({ engine: 'handlebars', directory: TEMPLATES, inPlace: true })
));

// Usual transforms
smithy.use(metallic());

smithy.use(md({
  extensions: ['footnote']
}))

// Templates layout
smithy.use(templates({ engine: 'handlebars', directory: TEMPLATES }));

smithy.use(sass({
  outputStyle: PROD ? "compressed" : "nested",
  sourceMapContents: !PROD,
  sourceMapEmbed: !PROD,
  sourceMap: !PROD
}));

smithy.use(autoprefixer());

smithy.use(browserify("bundle.js"));

if (PROD) {
  smithy.use(imagemin({
    optimizationLevel: 3,
    progressive: true
  }));
}

smithy.use(feed({
  collection: 'blog'
}));

// Actual build
smithy.destination(DESTINATION);
smithy.build(function(err) {
	if (err) {
    throw err;
  } else if (!PROD) {
    notifier.notify({
      title: 'Metalsmith',
      message: 'Finished forging your site',
    });
  }
});
