module.exports = (grunt) ->

    (require 'load-grunt-tasks')(grunt)
    (require 'time-grunt')(grunt)

    cfg =
        assets_src: '_assets'
        assets_target: 'assets'
        jekyll_target: '_site'
        bower: 'bower_components'

    grunt.initConfig
        cfg: cfg,
        pkg: grunt.file.readJSON "package.json"
        banner: "/*! [<%= pkg.author.name %>] : <%= pkg.name %> - v<%= pkg.version %>:<%= grunt.template.today('yyyy-mm-dd') %> */"

        clean: ["<%= cfg.jekyll_target %>", "<%= cfg.assets_target %>"]

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
            jekyll:
                files: ["_posts/{*,**}.{md,markdown}",
                        "{_layouts,_includes}/{*,**}.html",
                        "_plugins/{*,**}.rb",
                        "assets/{*,**}"]
                tasks: ["jekyll:dev", ]
                options:
                    livereload: 1337

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
                tasks: ["watch:jekyll", "connect:debug"]
                options:
                    logConcurrentOutput: true


    grunt.registerTask "build_dev", ["clean", "jekyll:dev"]

    grunt.registerTask "default", ["build_dev", "concurrent:dev"]