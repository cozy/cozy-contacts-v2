###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

Router = require 'routes'

ConfigModel = require 'models/config'

ContactsCollection = require 'collections/contacts'
TagsCollection     = require 'collections/tags'

AppLayout     = require 'views/app_layout'
AppViewModel  = require 'views/models/app'
IntentManager = require 'lib/intent_manager'


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
            config    = new ConfigModel require('imports').config
            @model    = new AppViewModel null, model: config

            @contacts = new ContactsCollection()
            @tags     = new TagsCollection()

            @layout   = new AppLayout model: @model
            @router   = new Router()

            @intentManager = new IntentManager

            Object.freeze @ if typeof Object.freeze is 'function'

        # render components when app starts
        @on 'start', =>
            @contacts.fetch reset: true
            @tags.fetch reset: true
            @layout.render()

            # prohibit pushState because URIs mapped from cozy-home rely on
            # fragment
            Backbone.history.start pushState: false if Backbone.history


    search: (pattern, string) ->
        filter  = @model.get 'filter'
        input   = "`#{pattern}:#{string}`"
        pattern = require('config').search.pattern pattern
        prev    = filter?.match pattern

        if string
            if prev
                filter = filter.replace pattern, input
            else if filter?.length
                filter += input
            else
                filter = input

        else if prev
            filter = filter.replace(pattern, '')

        @model.set 'filter', filter


# Exports Application singleton instance
module.exports = new Application()
