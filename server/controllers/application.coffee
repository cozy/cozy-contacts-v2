Contact = require '../models/contact'
Config  = require '../models/config'
Tag = require '../models/tag'
WebDavAccount = require '../models/webdavaccount'
async   = require 'async'
cozydb = require 'cozydb'

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

        locale = instance?.locale or 'en'
        if webDavAccount?
                webDavAccount.domain = instance?.domain or ''

        callback null, """
            window.config = #{JSON.stringify(config)};
            window.locale = "#{locale}";
            window.initcontacts = #{JSON.stringify(contacts)};
            window.tags = #{JSON.stringify(tags)};
            window.webDavAccount = #{JSON.stringify webDavAccount};
            window.inittags = #{JSON.stringify(tagInstances)}
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
