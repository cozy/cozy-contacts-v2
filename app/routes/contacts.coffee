app = undefined

module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        'new':        'create'
        'duplicates': 'duplicates'
        ':slug':      'show'
        ':slug/edit': 'edit'
        '':           'index'


    initialize: ->
        app = require 'application'


    _ensureContacts: (callback) ->
        return unless _.isFunction callback
        if app.contacts.isEmpty()
            @listenToOnce app.contacts, 'sync', callback
        else
            callback()


    _setCardState: (id, edit) ->
        dialog = id in app.contacts.pluck('id') or id is 'new'
        app.model.set 'dialog', if dialog then id else false
        app.channel.trigger 'mode:edit', edit


    index: ->
        app.search 'tag', null


    show: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id)


    edit: (id) ->
        @_ensureContacts _.wrap @_setCardState, (fn) -> fn(id, true)


    create: ->
        @_setCardState 'new', true


    duplicates: ->
        @_ensureContacts ->
            $($('nav a').get(1)).attr 'aria-busy', true
            setTimeout ->
                app.model.set 'dialog', 'duplicates'
            , 500

