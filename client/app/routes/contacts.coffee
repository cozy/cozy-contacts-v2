module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        '':      'index'
        ':slug': 'show'


    initialize: ->
        app = require 'application'
        app.layout.on 'click:backdrop', => @navigate 'contacts'


    index: ->


    show: (id) ->
        app = require 'application'
        show = ->
            model = app.contacts.get id
            if model?
                app.layout.showContact model
            else
                app.router.navigate 'contacts'

        if app.contacts.isEmpty()
            @listenTo app.contacts, 'sync', show
        else
            show()
