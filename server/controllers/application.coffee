fs = require 'fs'
path = require 'path'
Contact = require '../models/contact'
Config  = require '../models/config'
Tag = require '../models/tag'
WebDavAccount = require '../models/webdavaccount'
async   = require 'async'
cozydb = require 'cozydb'
log = require('printit')
    prefix: 'contact:application'

getImports = (callback) ->
    async.parallel [
        Config.getInstance
        (cb) -> cozydb.api.getCozyInstance cb
        (cb) -> WebDavAccount.first cb
    ], (err, res) ->
        [config, instance, webDavAccount] = res

        locale = instance?.locale or 'en'
        if webDavAccount?
            webDavAccount.domain = instance?.domain or ''

        callback null,
            config:        config
            locale:        locale
            webDavAccount: webDavAccount
            env:           process.env.NODE_ENV


module.exports =

    index: (req, res) ->
        getImports (err, imports) ->
            return res.error 500, 'An error occured', err if err

            res.render "index",
                imports: JSON.stringify(imports)
                locale:  imports.locale


    setConfig: (req, res) ->
        Config.set req.body, (err, config) ->
            return res.error 500, 'An error occured', err if err
            res.send config

    logClient: (req, res) ->
        data = req.body
        error = data.error
        delete data.error

        type = if data.type is 'log' then 'debug' else data.type

        log[type] data
        log[type] error.msg
        log[type] error.stack if error.stack

        res.status(204).send()
