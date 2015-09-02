module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        ':slug':      'show'
        ':slug/edit': 'edit'


    initialize: ->
        app = require 'application'
        app.model.on 'change:dialog', (model, value) =>
            @navigate 'contacts' unless value


    _ensureContacts: (callback) ->
        return unless _.isFunction callback
        app = require 'application'
        if app.contacts.isEmpty()
            @listenToOnce app.contacts, 'sync', callback
        else
            callback()


    _setCardState: (id, edit = false) ->
        app = require 'application'
        app.model.set 'dialog', if app.contacts.get(id) then id else false
        app.model.set 'editing', edit


    show: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id)


    edit: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id, true)
