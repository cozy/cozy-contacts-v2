module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        'new':        'create'
        'merge': 'merge'
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
        dialog = if app.contacts.get(id) or id is 'new' then id else false
        app.model.set 'dialog', dialog
        app.trigger 'mode:edit', edit


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
        app.model.set 'dialog', 'duplicates'
        # app.trigger 'mode:edit', true

    merge: ->
        # TODO
        app = require 'application'
        app.model.set 'dialog', 'merge'
