$ ->


    homeGoTo = (url) ->
        console.log "HOME GO TO CALLED"
        intent =
            action: 'goto'
            params: url

        window.parent.postMessage intent, window.location.origin

    @locale = window.locale
    delete window.locale

    @polyglot = new Polyglot()
    try
        locales = require 'locales/'+ @locale
    catch e
        locales = require 'locales/en'

    @polyglot.extend locales
    window.t = @polyglot.t.bind @polyglot

    class Router extends Backbone.Router
        routes: 'contact/:id' : 'goto'
        goto: (id) ->
            console.log "goto called"
            homeGoTo 'contacts/contact/' + id

    ContactsCollection = require('collections/contact')
    ContactsList = require('views/contactslist')
    @contacts = new ContactsCollection()
    @contactslist = new ContactsList collection: @contacts
    @contactslist.$el.appendTo $('body')
    @contactslist.render()
    @contacts.reset window.initcontacts
    @contactslist.$el.appendTo $('body')

    gotoapp = $("""
        <a id="gotoapp" href="/apps/contacts/">
            <i class="icon-share-alt"></i>
        </a>
    """).click (e) ->
        homeGoTo 'contacts'
        e.preventDefault()
        false

    $('body').append gotoapp

    router = new Router()
    Backbone.history.start()
