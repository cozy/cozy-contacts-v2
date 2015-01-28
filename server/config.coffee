americano = require 'americano'
path = require 'path'

module.exports =

    common:
        use: [
            americano.static path.resolve(__dirname, '../client/public'),
                maxAge: 86400000
            americano.bodyParser keepExtensions: true
            require('./helpers/shortcut')
        ]
        afterStart: (app, server) ->
            # move it here needed after express 4.4
            app.use americano.errorHandler
                dumpExceptions: true
                showStack: true
        set:
            views: path.join __dirname, 'views'

        engine:
            js: (path, locales, callback) ->
                callback null, require(path)(locales)

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: [
        'cozydb'
    ]
