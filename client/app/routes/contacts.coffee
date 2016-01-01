module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        'new':        'create'
        'duplicates': 'duplicates'
        ':slug':      'show'
        ':slug/edit': 'edit'
        '':           'index'


    _ensureContacts: (callback) ->
        return unless _.isFunction callback
        app = require 'application'
        if app.contacts.isEmpty()
            @listenToOnce app.contacts, 'sync', callback
        else
            callback()


    _setCardState: (id, edit) ->
        app    = require 'application'
        dialog = id in app.contacts.pluck('id') or id is 'new'
        app.model.set 'dialog', if dialog then id else false
        app.vent.trigger 'mode:edit', edit


    index: ->
        app = require 'application'
        app.search 'tag', null


    show: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id)


    edit: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id, true)


    create: ->
        @_setCardState 'new', true


    duplicates: ->
        app = require 'application'
        @_ensureContacts -> app.model.set 'dialog', 'duplicates'
