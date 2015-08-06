###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

Router    = require 'routes'
AppLayout = require 'views/app_layout'


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
            @layout = new AppLayout()
            @router = new Router()

            # prohibit pushState because URIs mapped from cozy-home rely on
            # fragment
            Backbone.history.start pushState: false if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'

        # render components awhen app starts
        @on 'start', =>
            @layout.render()



# Exports Application singleton instance
module.exports = new Application()
