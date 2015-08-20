###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

Router             = require 'routes'
ContactsCollection = require 'collections/contacts'
AppLayout          = require 'views/app_layout'
AppViewModel       = require 'views/models/app'


class Application extends Mn.Application

    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        # initialize components before loading app
        @on 'before:start', =>
            @model    = new AppViewModel()
            @contacts = new ContactsCollection()
            @layout   = new AppLayout model: @model
            @router   = new Router()

            # prohibit pushState because URIs mapped from cozy-home rely on
            # fragment
            Backbone.history.start pushState: false if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'

        # render components when app starts
        @on 'start', =>
            @layout.render()
            @contacts.fetch()


# Exports Application singleton instance
module.exports = new Application()
