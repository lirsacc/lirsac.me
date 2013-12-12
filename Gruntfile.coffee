module.exports = (grunt) ->

    (require "load-grunt-tasks")(grunt)
    (require "time-grunt")(grunt)

    cfg =
        assets_src: "_assets"
        assets_target: "assets"
        jekyll_target: "_site"
        bower: "bower_components"
        tmp: ".tmp"

    grunt.initConfig
        cfg: cfg,
        pkg: grunt.file.readJSON "package.json"
        banner: "/*! [<%= pkg.author.name %>] : <%= pkg.name %> - v<%= pkg.version %>:<%= grunt.template.today('yyyy-mm-dd') %> */"

        clean:
            tmp: ["<%= cfg.tmp %>", "<%= cfg.assets_target %>"]
            build: ["<%= cfg.jekyll_target %>", "<%= cfg.tmp %>", "<%= cfg.assets_target %>"]
            dependencies: ["<%= cfg.bower %>", "node_modules", ".sass-cache"]

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

        scsslint:
            allFiles: ['<%= cfg.assets_src %>/scss/{*,**}.scss']
            options:
              reporterOutput: null

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

        uglify:
            build:
                options:
                    banner: "<%= cfg.banner %>"
                    preserveComments: false
                files: "<%= cfg.assets_target %>/js/app.js": "<%= cfg.assets_target %>/js/app.js"

        copy:
            assets:
                cwd: "<%= cfg.assets_src %>"
                expand: true
                src: "fonts/**"
                dest: "<%= cfg.assets_target %>"

        jekyll:
            options:
                dest: "<%= cfg.jekyll_target %>"
            build:
                drafts: false
                future: false
            dev:
                drafts: true
                future: true

        watch:
            options:
                debounceDelay: 250
            assets:
                files: ["<%= cfg.assets_src %>/{fonts}/**"]
                tasks: ["copy:assets"]
            style:
                files: ["<%= cfg.assets_src %>/scss/**/*.scss"]
                tasks: ["sass:dev"]
            js:
                files: ["<%= cfg.assets_src %>/coffee/{*,**}.coffee"]
                tasks: ["coffelint", "coffee:dev"]
            jekyll:
                files: ["_posts/{*,**}.{md,markdown}",
                        "{_layouts,_includes}/*.html",
                        "_plugins/{*,**}.rb",
                        "assets/{*,**}",
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
                    port: 8080
                    keepalive: true
                    hostname: "localhost"
                    base: "<%= cfg.jekyll_target %>"
                    open: true
            debug:
                options:
                    port: 9090
                    keepalive: true
                    hostname: "localhost"
                    base: "_site"
                    open: true
                    debug: true
                    livereload: 1337

        concurrent:
            dev:
                tasks: ["watch:jekyll", "watch:style", "watch:js", "connect:debug"]
                options:
                    logConcurrentOutput: true

        bump:
            options:
                tabSize: 4
            files: ["bower.json", "package.json"]

    grunt.registerTask "dev", ["clean:build",
                               "scsslint", "sass:dev",
                               "coffeelint", "coffee:dev",
                               "copy:assets",
                               "jekyll:dev"]

    grunt.registerTask "build", ["clean:build",
                                 "scsslint", "sass:build",
                                 "coffeelint", "coffee:build", "uglify:build",
                                 "copy:assets",
                                 "jekyll:build"
                                 "clean:tmp"]

    grunt.registerTask "default", ["dev", "concurrent:dev"]
