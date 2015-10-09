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
        log.error req.body.data
        log.error req.body.data.error?.stack
        res.send 'ok'
