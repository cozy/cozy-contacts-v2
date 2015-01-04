ContactListener = require 'lib/contact_listener'
IntentManager   = require 'lib/intent_manager'

module.exports =

    initialize: ->
        window.app = @

        @locale = window.locale
        delete window.locale

        @polyglot = new Polyglot()
        try
            locales = require 'locales/'+ @locale
        catch e
            locales = require 'locales/en'

        @polyglot.extend locales
        window.t = @polyglot.t.bind @polyglot

        ContactsCollection = require('collections/contact')
        TagCollection = require 'collections/tags'
        ContactsList = require('views/contactslist')
        Config = require('models/config')
        Router = require('router')

        @contacts = new ContactsCollection()
        @tags = new TagCollection()
        @contactslist = new ContactsList collection: @contacts
        @contactslist.$el.appendTo $('body')
        @contactslist.render()

        @watcher = new ContactListener()
        @watcher.watch @contacts

        @config = new Config(window.config or {})
        delete window.config

        if window.initcontacts?
            @contacts.reset window.initcontacts, parse: true
            delete window.initcontacts
        else
            @contacts.fetch()

        if window.inittags?
            @tags.reset window.inittags, parse: true
        else
            @tags.fetch()

        @router = new Router()


        Backbone.history.start()

        @intentManager = new IntentManager()


