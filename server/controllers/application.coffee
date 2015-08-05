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
        (cb) -> Contact.all cb
        Config.getInstance
        (cb) -> cozydb.api.getCozyInstance cb
        (cb) -> cozydb.api.getCozyTags cb # All tags values in cozy.
        (cb) -> WebDavAccount.first cb
        Tag.all # tags instances (with color).
    ], (err, results) ->
        [contacts, config, instance, tags, webDavAccount, tagInstances] = results

        # Remove this fix once cozydb is fixed:
        # https://github.com/cozy/cozydb/issues/6
        if tags?
            tags = tags.filter (value) ->
                Boolean(value)
        else
            tags = []

        locale = instance?.locale or 'en'
        if webDavAccount?
            webDavAccount.domain = instance?.domain or ''

        callback null,
            config:        config
            locale:        locale
            initcontacts:  contacts
            tags:          tags
            webDavAccount: webDavAccount
            inittags:      tagInstances


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
