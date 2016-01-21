path = require 'path'

if process.env.USE_JS
    prefix = path.join __dirname, '../build/'
else
    prefix = path.join __dirname, '../'

Contact = require "#{prefix}server/models/contact"
Config = require "#{prefix}server/models/config"
Client = require('request-json').JsonClient
ds = require 'cozydb/lib/utils/client'

options =
    host: 'localhost'
    port: process.env.PORT or 8013
    root: prefix

module.exports =
    prefix: prefix

    startServer: (done) ->
        @timeout 6000
        start = require "#{prefix}server"
        start options, (err, app, server) =>
            @server = server
            done err

    killServer: ->
        @server.close()

    clearDb: (done) ->
        Config.requestDestroy "all", ->
            Contact.requestDestroy "all", ->
                done()

    createContact: (data) -> (done) ->
        baseContact = new Contact(data)
        Contact.create baseContact, (err, contact) =>
            @contact = contact
            done err

    createRaw: (data) -> (done) ->
        ds.post '/data/', data, (err, res, body) =>
            @created = body
            done err

    makeTestClient: (done) ->
        old = new Client "http://localhost:#{options.port}/"
        old.headers['accept'] = 'application/json'

        store = this # this will be the common scope of tests

        callbackFactory = (done) -> (error, response, body) =>
            return done error if error
            store.response = response
            store.body = body
            done()

        clean = ->
            store.response = null
            store.body = null

        store.client =
            get: (url, done, parse) ->
                clean()
                old.get url, callbackFactory(done), parse
            post: (url, data, done) ->
                clean()
                old.post url, data, callbackFactory(done)
            put: (url, data, done) ->
                clean()
                old.put url, data, callbackFactory(done)
            del: (url, done) ->
                clean()
                old.del url, callbackFactory(done)
            sendFile: (url, path, done) ->
                old.sendFile url, path, callbackFactory(done)
            saveFile: (url, path, done) ->
                old.saveFile url, path, callbackFactory(done)

        done()
