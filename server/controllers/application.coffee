Contact = require '../models/contact'
Config  = require '../models/config'
WebDavAccount = require '../models/webdavaccount'
async   = require 'async'
cozydb = require 'cozydb'

getImports = (callback) ->
    async.parallel [
        (cb) -> Contact.all cb
        Config.getInstance
        (cb) -> cozydb.api.getCozyInstance cb
        (cb) -> cozydb.api.getCozyTags cb
        (cb) -> WebDavAccount.first cb
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

            res.render 'index.js', imports: imports


    setConfig: (req, res) ->
        Config.set req.body, (err, config) ->
            return res.error 500, 'An error occured', err if err
            res.send config
