exports.config =
    files:
        javascripts:
            joinTo:
                'scripts/vendor.js': /^(bower_components|vendor)/
                'scripts/app.js': /^app/
                'test/scripts/test.js': /^test\/(?!vendor)/
                'test/scripts/test-vendor.js': /^test\/(?=vendor)/
            order:
                before: [
                    'vendor/marionette/lodash.js'
                    'vendor/marionette/jquery.js'
                    'vendor/marionette/backbone.js'
                    'vendor/marionette/backbone.babysitter.js'
                    'vendor/marionette/backbone.radio.js'
                    'vendor/marionette/backbone.marionette.js'
                    'vendor/marionette/radio.shim.js'
                ]

        stylesheets:
            joinTo:
                'stylesheets/app.css': /^(bower_components|vendor|app)/
                'test/stylesheets/test.css': /^test/

        templates:
            defaultExtension: 'jade'
            joinTo: 'scripts/app.js'


    conventions:
        ignored: [
            /[\\/]_/
            /[\\/]index.styl/
        ]


    plugins:
        browserSync:
            notify: false

        coffeelint:
            pattern: /^app\/.*\.coffee$/
            options:
                indentation:
                    value: 4
                    level: 'error'

        jade:
            globals: ['t', 'moment', '_', 'ColorHash']

        stylus:
            plugins: [
                'cozy-ui/lib/stylus'
            ]

        postcss:
            processors: [
                require('autoprefixer')(['last 2 versions'])
            ]


    overrides:
        production:
            paths:
                watched: ['app', 'vendor']
                public: '../build/client/public'

            plugins:
                postcss:
                    processors: [
                        require('autoprefixer')(['last 2 versions'])
                        require('css-mqpacker')
                        require('csswring')
                    ]
