Contact = require '../models/contact'
Config  = require '../models/config'
CozyInstance = require '../models/cozy_instance'
WebDavAccount = require '../models/webdavaccount'
async   = require 'async'
Client  = require('request-json').JsonClient

getImports = (callback) ->
    async.parallel [
        (cb) -> Contact.request 'all', cb
        Config.getInstance
        CozyInstance.first
        (cb) ->
            dataSystem = new Client "http://localhost:9101/"
            dataSystem.get 'tags', (err, response, body) -> cb err, body
        WebDavAccount.first
    ], (err, results) ->
        [contacts, config, instance, tags, webDavAccount] = results

        locale = instance?.locale or 'en'
        if webDavAccount?
                webDavAccount.domain = instance?.domain or ''

        callback null, """
            window.config = #{JSON.stringify(config)};
            window.locale = "#{locale}";
            window.initcontacts = #{JSON.stringify(contacts)};
            window.tags = #{JSON.stringify(tags)};
            window.webDavAccount = #{JSON.stringify webDavAccount};
        """


module.exports =

    index: (req, res) ->
        getImports (err, imports) ->
            return res.error 500, 'An error occured', err if err

            res.render 'index.jade', imports: imports


    widget: (req, res) ->
        getImports (err, imports) ->
            return res.error 500, 'An error occured', err if err

            res.render 'widget.jade', imports: imports


    setConfig: (req, res) ->
        Config.set req.body, (err, config) ->
            return res.error 500, 'An error occured', err if err
            res.send config
