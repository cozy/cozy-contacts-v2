###
Main application Router

Handles routes exposed by the application. It generate views/viewModels couples
when needed and show them in the app_layout regions.
###

ContactsRouter = require 'routes/contacts'
TagsRouter     = require 'routes/tags'

app = undefined


module.exports = class Router extends Backbone.Router

    routes:
        'settings':      'settings'
        'contact/:slug': 'legacyContactRedirect'
        '':              'index'


    initialize: ->
        # we initialize sub-routers only when app starts to prevent a bug that
        # crashes subrouters if they are loaded before Backbone.History is
        # started (in `app:before:start` event).
        #
        # see https://github.com/BackboneSubroute/backbone.subroute/issues/3
        app = require 'application'

        app.on 'start', ->
            contacts = new ContactsRouter 'contacts'
            tags     = new TagsRouter 'tags'

        @listenTo app.model, 'change:dialog', (model, id) ->
            return if id

            filter = app.model.get('filter')?.match /tag:(\w+)/i
            path   = if filter then "tags/#{filter[1]}" else 'contacts'
            @navigate path


    index: ->
        @navigate 'contacts', trigger: true


    settings: ->
        app.model.set 'dialog', 'settings'

    legacyContactRedirect: (slug) ->
        @navigate "contacts/#{slug}", trigger: true

