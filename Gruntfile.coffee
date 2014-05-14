module.exports = (grunt) ->

    (require "load-grunt-tasks")(grunt)
    (require "time-grunt")(grunt)

    cfg =
        assets_src: "_assets"
        assets_target: "assets"
        jekyll_target: "_site"
        bower: "bower_components"
        tmp: ".tmp"

        host: "localhost"
        port: 9090

    javascriptSources = ["<%= cfg.assets_target %>/js/app.js"]

    grunt.initConfig

        cfg: cfg,
        pkg: grunt.file.readJSON "package.json"
        banner: "/*! [<%= pkg.author.name %>] : <%= pkg.name %> - v<%= pkg.version %>:<%= grunt.template.today('yyyy-mm-dd') %> */\n"

        clean:
            tmp: ["<%= cfg.tmp %>", "<%= cfg.assets_target %>"]
            build: ["<%= cfg.jekyll_target %>", "<%= cfg.tmp %>", "<%= cfg.assets_target %>"]
            dependencies: ["<%= cfg.bower %>", "node_modules", ".sass-cache"]

        bump:
            options:
                files: ['package.json', 'bower.json']
                commit: true,
                commitMessage: 'Release v%VERSION%'
                commitFiles: ['package.json', 'bower.json'] # '-a' for all files
                createTag: true
                tagName: 'v%VERSION%'
                tagMessage: 'Version %VERSION%'
                push: false
                pushTo: 'origin'
                gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d' # options to use with '$ git describe'

        scsslint:
            allFiles: ['<%= cfg.assets_src %>/scss/**/*.scss']
            options:
                config: '.scss-lint.yml'

        sass:
            dev:
                options:
                    style: "expanded"
                    banner: "<%= banner %>"
                    precision: 4
                    lineNumbers: true
                    unixNewlines: true
                    trace: true
                    sourcemap: true
                    quiet: true
                files:
                    "<%= cfg.assets_target %>/css/style.css": "<%= cfg.assets_src %>/scss/style.scss"
            build:
                options:
                    banner: "<%= banner %>"
                    noCache: true
                    quiet: true
                    precision: 4
                    style: "compressed"
                    unixNewlines: true
                files:
                    "<%= cfg.assets_target %>/css/style.css": "<%= cfg.assets_src %>/scss/style.scss"

        coffee:
            dev:
                options:
                    join: true
                    sourceMap: true
                files: "<%= cfg.assets_target %>/js/app.js": ["<%= cfg.assets_src %>/coffee/{*,**}.coffee"]
            build:
                options:
                    join: true
                    sourceMap: false
                files: "<%= cfg.assets_target %>/js/app.js": ["<%= cfg.assets_src %>/coffee/{*,**}.coffee"]

        coffeelint:
            app: ["<%= cfg.assets_src %>/coffee/{*,**}.coffee"]
            options:
                arrow_spacing:
                    level: "warn"
                camel_case_classes:
                    level: "warn"
                no_tabs:
                    level: "error"
                coffeescipt_error:
                    level: "error"
                no_trailing_semicolons:
                    level: "error"
                indentation:
                    value: 4
                    level: "error"
                max_line_length:
                    level: "warn"
                    value: 80

        autoprefixer:
            options:
                browsers: ['last 4 version', '> 4%']
            simple:
                src: "<%= cfg.assets_target %>/css/style.css"
                dest: "<%= cfg.assets_target %>/css/style.css"
            build:
                src: "<%= cfg.assets_target %>/css/style.css"
                dest: "<%= cfg.assets_target %>/css/style.css"

        concat:
            options:
                banner: "<%= banner %>"
                stripBanners: true
            js:
                src: javascriptSources
                dest: "<%= cfg.assets_target %>/js/app.js"

        uglify:
            options:
                    banner: "<%= cfg.banner %>"
            build:
                files: "<%= cfg.assets_target %>/js/app.js": javascriptSources

        copy:
            assets:
                cwd: "<%= cfg.assets_src %>"
                expand: true
                src: "{fonts,icons,img}/**"
                dest: "<%= cfg.assets_target %>"

        htmlmin:
            build:
                options:
                    collapseWhitespace: true
                    removeEmptyAttributes: true
                    useShortDoctype: true
                    removeRedundantAttributes: true
                    collapseBooleanAttributes: true
                expand: true,
                cwd: "_site"
                src: ["**/*.html"]
                dest: "_site/"

        jekyll:
            options:
                dest: "<%= cfg.jekyll_target %>"
            build:
                options:
                    config: "_config.yml"
                    drafts: false
                    future: false
            dev:
                options:
                    config: "_config.yml"
                    drafts: true
                    future: true
                    raw: 'url: http://localhost:9090/\n'

        watch:
            options:
                debounceDelay: 250
            assets:
                files: ["<%= cfg.assets_src %>/{fonts}/**"]
                tasks: ["copy:assets"]
            style:
                files: ["<%= cfg.assets_src %>/scss/**/*.scss"]
                tasks: ["sass:dev", "autoprefixer:simple"]
            js:
                files: ["<%= cfg.assets_src %>/coffee/{*,**}.coffee"]
                tasks: ["coffeelint", "coffee:dev", "concat:js"]
            jekyll:
                files: ["{_posts,_drafts}/{*,**}.{html,md,markdown}",
                        "{_layouts,_includes}/*.html",
                        "{blog,404}/*.{html,md,markdown}",
                        "index.{html,md,markdown}",
                        "_plugins/{*,**}.rb",
                        "assets/{*,**}",
                        "_data/*.yml",
                        "_config.yml"]
                tasks: ["jekyll:dev", "notify:jekyll"]
                options:
                    livereload: 1337

        notify:
            jekyll:
                options:
                    title: "Jekyll build"
                    message: "Jekyll has just finished building the site. Open pages have been reloaded through port 1337."

        connect:
            serve:
                options:
                    port: "<%= cfg.port %>"
                    keepalive: true
                    hostname: "<%= cfg.hostname %>"
                    base: "<%= cfg.jekyll_target %>"
            debug:
                options:
                    port: "<%= cfg.port %>"
                    keepalive: true
                    hostname: "<%= cfg.hostname %>"
                    base: "<%= cfg.jekyll_target %>"
                    debug: true
                    livereload: 1337

        concurrent:
            dev:
                tasks: ["watch:jekyll", "watch:style", "watch:js", "connect:debug"]
                options:
                    logConcurrentOutput: true


    grunt.registerTask "dev", ["clean:build",
                               "sass:dev", "autoprefixer:simple"
                               "coffeelint", "coffee:dev", "concat:js",
                               "copy:assets",
                               "jekyll:dev"]

    grunt.registerTask "build", ["clean:build",
                                 "sass:build", "autoprefixer:build"
                                 "coffeelint", "coffee:build", "uglify:build",
                                 "copy:assets",
                                 "jekyll:build",
                                 "htmlmin:build",
                                 "clean:tmp"]

    grunt.registerTask "default", ["dev", "concurrent:dev"]
