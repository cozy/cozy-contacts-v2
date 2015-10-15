###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

Router = require 'routes'

ContactsCollection = require 'collections/contacts'
TagsCollection     = require 'collections/tags'

AppLayout    = require 'views/app_layout'
AppViewModel = require 'views/models/app'
IntentManager   = require 'lib/intent_manager'


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
            @tags     = new TagsCollection()

            @layout   = new AppLayout model: @model
            @router   = new Router()

            # prohibit pushState because URIs mapped from cozy-home rely on
            # fragment
            Backbone.history.start pushState: false if Backbone.history

            @intentManager = new IntentManager

            Object.freeze @ if typeof Object.freeze is 'function'


        # render components when app starts
        @on 'start', =>
            @layout.render()
            @contacts.fetch reset: true
            @tags.fetch reset: true


    search: (pattern, string) ->
        filter  = @model.get 'filter'
        input   = "#{pattern}:#{string}"
        pattern = new RegExp "#{pattern}:([^\\s]+)", 'i'
        prev    = filter?.match pattern or null

        if string
            if prev
                filter = filter.replace pattern, input
            else if filter?.length
                filter += " #{input}"
            else
                filter = input

        else if prev
            filter = filter.replace(pattern, '').trim()

        @model.set 'filter', filter


# Exports Application singleton instance
module.exports = new Application()
