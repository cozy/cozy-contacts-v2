module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        ':slug':      'show'
        ':slug/edit': 'edit'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:dialog', (model, id) ->
            @navigate 'contacts' unless id


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
        app.trigger 'mode:edit', edit


    show: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id)


    edit: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id, true)
