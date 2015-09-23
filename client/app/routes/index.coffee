###
Main application Router

Handles routes exposed by the application. It generate views/viewModels couples
when needed and show them in the app_layout regions.
###

ContactsRouter = require 'routes/contacts'


module.exports = class Router extends Backbone.Router

    routes:
        '': 'index'


    initialize: ->
        # we initialize sub-routers only when app starts to prevent a bug that
        # crashes subrouters if they are loaded bafore Backbone.History is
        # started (in `app:before:start` event).
        #
        # see https://github.com/BackboneSubroute/backbone.subroute/issues/3
        app = require 'application'
        app.on 'start', ->
            contacts = new ContactsRouter 'contacts'
        app.contacts.once 'sync', ->
            app.layout.showContactsList()
            app.layout.disableBusyState()


    index: ->
        @navigate 'contacts', trigger: true
