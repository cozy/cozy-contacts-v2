americano = require 'cozydb'

module.exports = Config = americano.getModel 'ContactConfig',
    nameOrder: type: String, default: 'not-set'
    sort: type: String, default: 'fn'

Config.getInstance = (callback) ->
    Config.request 'all', (err, configs) ->
        return callback err if err

        config = configs?[0] or new Config()
        callback null, config.toJSON()

Config.set = (hash, callback) ->
    Config.request 'all', (err, configs) ->
        return callback err if err

        if (config = configs?[0])
            config.updateAttributes hash, callback
        else
            Config.create hash, callback
