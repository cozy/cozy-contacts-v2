americano = require 'americano'
Realtimer = require 'cozy-realtime-adapter'


module.exports = application = (options = {}, callback = ->) ->
    options.name = 'Contacts'
    options.root ?= __dirname
    options.port ?= process.env.PORT or 9114
    options.host ?= process.env.HOST or '127.0.0.1'

    americano.start options, (err, app, server) ->
        realtime = Realtimer server, ['contact.*', 'tag.*']
        callback? null, app, server


if not module.parent
    application()
