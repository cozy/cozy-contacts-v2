fs          = require 'fs'
path        = require 'path'
americano   = require 'americano'
compression = require 'compression'

viewsDir = path.resolve __dirname, 'views'
useBuildView = fs.existsSync path.resolve viewsDir, 'index.js'

module.exports =

    common:
        use: [
            compression()
            americano.static path.resolve(__dirname, '../client/public'),
                maxAge: 86400000
            americano.bodyParser limit: '1mb', keepExtensions: true
            require('./helpers/shortcut')
        ]
        afterStart: (app, server) ->
            app.use (req, res) -> res.end()
            # move it here needed after express 4.4
            app.use americano.errorHandler
                dumpExceptions: true
                showStack: true
        set:
            'view engine': if useBuildView then 'js' else 'jade'
            'views': viewsDir

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
