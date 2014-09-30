'use strict';

var gulp =          require('gulp'),
    pkg =           require('./package.json'),
    path =          require('path'),
    args =          require('yargs').argv;

var plugins =       require('gulp-load-plugins')();

var browserify =    require('browserify'),
    coffeeify =     require('coffeeify'),
    source =        require('vinyl-source-stream'),
    buffer =        require('vinyl-buffer'),
    del =           require('del'),
    spawn =         require('child_process').spawn,
    express =       require('express'),
    livereload =    require('tiny-lr');

var ENV = process.env.NODE_ENV;
var PROD = ENV  === 'production' || args.production || args.prod || args.p;

var ROOT = path.normalize(__dirname + '/.');

var paths = {
    dest:   path.join(ROOT, 'assets'),
    src:    path.join(ROOT, '_assets'),
    tmp:    path.join(ROOT, '.tmp'),
    site:   path.join(ROOT, '_site')
}

var SERVER_ROOT =       paths.site + '/',
    SERVER_HOST =       '127.0.0.1',
    SERVER_PORT =       9090,
    LIVERELOAD_PORT =   35729;

var lr;

/*  Error handler
-------------------------------------------------------------------------*/

function logErrors () {
    var args = Array.prototype.slice.call(arguments);
    plugins.util.log(plugins.util.colors.red('<Gulp Error>', args));
    this.emit('end');
}

/*  Sub Tasks
-------------------------------------------------------------------------*/

// Clean build contents
gulp.task('clean', function (cb) {
    del([ paths.tmp, paths.dest, paths.site, "./favicon*"], cb);
});

// Browserify tasks
gulp.task('browserify', function () {

    var bundler = browserify({
        entries: [ path.join(paths.src, 'coffee', 'app.coffee') ],
        debug: true
    });

    bundler.transform(coffeeify);

    var bundle = function () {
        var stream = bundler.bundle();

        var _ = stream.on('error', logErrors)
            .pipe(source('bundle.js'))
            .pipe(buffer())

        if (PROD) {
            _ = _.pipe(plugins.uglify());
        } else {
            _ = _.pipe(plugins.sourcemaps.init({loadMaps: true}))
                .pipe(plugins.uglify())
                .pipe(plugins.sourcemaps.write('./'))
        }

        return _.pipe(gulp.dest(paths.dest));
    }

    return bundle();
});

// Jekyll Task
gulp.task('jekyll', function (cb) {

    var jekyllArgs = [ 'build', '--config', '_config.yml' ];

    if (!PROD) {
        jekyllArgs.push.apply(jekyllArgs, [ '--drafts', '--future' ]);
    }

    var jekyll = spawn('jekyll', jekyllArgs);
    jekyll.on('exit', cb);
});

// Copy Task
gulp.task('copy', function () {
    gulp.src(path.join(paths.src, '{fonts/*.{eot,svg,ttf,woff},img/*}'))
        .pipe(gulp.dest(paths.dest));
});

gulp.task('favicon', function () {
    gulp.src(path.join(paths.src, 'favicon/*.{png,ico}'))
        .pipe(gulp.dest(ROOT));
});

// SCSS Task
gulp.task('scss', function () {

    return gulp.src(path.join(paths.src, 'scss', 'style.scss'))
        .pipe(plugins.sass({
            outputStyle: 'compact',
            precision: 10,
            sourceComments: PROD ? false: 'map',
            sourceMap: PROD ? false: 'scss'
        }))
        .pipe(plugins.autoprefixer({
             browsers: ['> 4%', 'last 4 versions'],
             cascade: false
        }))
        .pipe(PROD ? plugins.cssmin() : plugins.util.noop())
        .pipe(plugins.rename('bundle.css'))
        .pipe(gulp.dest(paths.dest))
});

// Run static file server
gulp.task('serve', function (cb) {
    var server = express();
    server.use(body.json())
          .use(require('connect-livereload')({ port: LIVERELOAD_PORT }))
          .use(express.static(SERVER_ROOT))
          .listen(SERVER_PORT, function () {
              plugins.util.log(plugins.util.colors.green(
                  'Server listening on port: ' + SERVER_PORT));
              cb();
          });
});

// Start LiveReload server
gulp.task('livereload', function (cb) {
    lr = livereload();
    lr.listen(LIVERELOAD_PORT, function () {
        plugins.util.log(plugins.util.colors.green(
            'Livereload listening on port: ' + LIVERELOAD_PORT));
        cb();
    });
});

function notifyLR (evt) {
    lr.changed({
        body: { files: [ path.relative(SERVER_ROOT, evt.path) ] }
    });
}

// Watch task
var watchOpts = { debounceDelay: 3000 };

gulp.task('watch', ['jekyll'], function () {

    gulp.watch(path.join(paths.src, 'coffee', '**', '*.coffee'),
               watchOpts,
               ['browserify']);

    gulp.watch(path.join(paths.src, 'scss', '**', '*.scss'),
               watchOpts,
               ['scss']);

    gulp.watch([
        'assets/**/*',
        '_data/*.yml', '_config.yml',
        '{_drafts,_posts}/*.{md,markdown}',
        '_plugins/*.rb',
        '*.html', '*/*.html',

        '!_site/**/*', '!_assets/**/*',
        '!bower_components/**/*', '!node_modules/**/*'
    ], watchOpts, [ 'jekyll' ]);

    gulp.watch(path.join(paths.site, '**', '*'), watchOpts).on('change', notifyLR);
});

// Bump version task
gulp.task('bump', function(cb) {
    var bumpType = null || args.type;
    return gulp.src('./{bower,package}.json')
            .pipe(!!bumpType ? plugins.bump({type: bumpType}) : plugins.bump())
            .pipe(gulp.dest('./'));
});

/*  Aggregate Tasks
-------------------------------------------------------------------------*/

gulp.task('assets', ['copy', 'favicon', 'browserify', 'scss']);

gulp.task('build', function (cb) {
    plugins.runSequence('clean', 'assets', 'jekyll', cb);
});

gulp.task('dev', function (cb) {
    plugins.runSequence(['build', 'livereload'], ['watch', 'serve'], cb);
});

gulp.task('default', ['dev']);
