module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        '':      'index'
        ':slug': 'show'


    _setInitialState: (callback) ->
        app = require 'application'
        @listenTo app.contacts, 'sync', ->
            app.layout.showContactsList()
            app.layout.disableBusyState()

        if callback and _.isFunction callback
            @listenTo app.contacts, 'sync', callback

        @listenTo app.layout.model, 'change:dialog', (model, value) =>
            @navigate 'contacts' unless value


    _setCardState: (id) ->
        app = require 'application'
        app.model.set 'dialog', if app.contacts.get(id) then id else false


    index: ->
        @_setInitialState()


    show: (id) ->
        app = require 'application'
        if app.contacts.isEmpty()
            @_setInitialState _.partial @_setCardState, id
        else
            @_setCardState id
