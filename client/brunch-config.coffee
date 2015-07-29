exports.config =
    files:
        javascripts:
            joinTo:
                'scripts/vendor.js': /^(bower_components|vendor)/
                'scripts/app.js': /^app/
            order:
                before: [
                    'bower_components/jquery/dist/jquery.js'
                ]

        stylesheets:
            joinTo: 'stylesheets/app.css'

        templates:
            defaultExtension: 'jade'
            joinTo: 'scripts/app.js'

    plugins:
        jade:
            globals: ['t', 'moment']
    
        coffeelint:
            options:
                indentation:
                    value: 4
                    level: 'error'

    overrides:
        production:
            paths:
                public: '../build/client/public'
