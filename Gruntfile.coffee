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
                    sourcemap: true
                files:
                    "<%= cfg.assets_target %>/css/style.css": "<%= cfg.assets_src %>/scss/style.scss"

        scsslint:
            allFiles: ['<%= cfg.assets_src %>/scss/{*,**}.scss']
            options:
              reporterOutput: null

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
                tasks: ["watch:jekyll", "watch:style", "connect:debug"]
                options:
                    logConcurrentOutput: true

        bump:
            options:
                tabSize: 4
            files: ["bower.json", "package.json"]

    grunt.registerTask "dev", ["clean:build", "sass:dev", "copy:assets", "jekyll:dev"]
    grunt.registerTask "build", ["clean:build", "sass:build", "copy:assets", "jekyll:build"]

    grunt.registerTask "default", ["dev", "concurrent:dev"]
