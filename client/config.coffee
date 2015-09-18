path = require 'path'
exports.config =

    plugins:
        coffeelint:
            options:
                indentation: value:4, level:'error'

    conventions:
        vendor: /(vendor)|(_specs)(\/|\\)/ # do not wrap tests in modules

    files:
        javascripts:
            defaultExtension: 'coffee'
            joinTo:
                'javascripts/app.js': /^app/
                'javascripts/vendor.js': /^vendor/
                '../_specs/specs.js': /^_specs.*\.coffee$/
            order:
                before: [
                    # Backbone
                    'vendor/scripts/jquery-2.1.1.js',
                    'vendor/scripts/underscore.js',
                    'vendor/scripts/backbone.js',
                    # Twitter Bootstrap jquery plugins
                    'vendor/scripts/bootstrap.js',
                    'vendor/scripts/utf8.js',
                    'vendor/scripts/quoted-printable.js'
                ]
                after: [
                    'vendor/scripts/cozy-vcard.js'
                ]
        stylesheets:
            defaultExtension: 'styl'
            joinTo:
                'stylesheets/app.css': /^app/
                'stylesheets/vendor.css': /^vendor/
            order:
                before: [
                    'vendor/styles/bootstrap.css'
                    'vendor/styles/bootstrap-responsive.css',
                ]
                after: []
        templates:
            defaultExtension: 'jade'
            joinTo: 'javascripts/app.js'

    plugins:
        jade:
            globals: ['t', 'moment']

    overrides:
        production:
            # re-enable when uglifyjs will handle properly in source maps
            # with sourcesContent attribute
            #optimize: true
            sourceMaps: true
            paths:
                public: path.resolve __dirname, '../build/client/public'

