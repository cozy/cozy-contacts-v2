###

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

Router = require 'routes'

ConfigModel = require 'models/config'

ContactsCollection = require 'collections/contacts'
FilteredCollection = require 'collections/filtered'
TagsCollection     = require 'collections/tags'

AppLayout    = require 'views/app_layout'
AppViewModel = require 'views/models/app'

IntentManager = require 'lib/intent_manager'


class Application extends Mn.Application

    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###

    # initialize components before loading app
    onBeforeStart: ->
        config    = new ConfigModel require('imports').config
        @model    = new AppViewModel null, model: config

        @contacts = new ContactsCollection()
        @filtered = new FilteredCollection()
        @tags     = new TagsCollection(@contacts)

        # As long as Tags require Contacts to be loaded (see Tags.refs), we
        # trigger all TagsCollection fetch after syncing ContactsCollection.
        @listenToOnce @contacts, 'sync': -> @tags.underlying.fetch reset: true

        @layout   = new AppLayout model: @model
        @router   = new Router()

        @intentManager = new IntentManager()

        Object.freeze @ if typeof Object.freeze is 'function'

    # render components when app starts
    onStart: ->
        @layout.render()
        @contacts.fetch reset: true

        # prohibit pushState because URIs mapped from cozy-home rely on
        # fragment
        Backbone.history.start pushState: false if Backbone.history


    search: (pattern, string) ->
        filter  = @model.get 'filter'
        input   = "`#{pattern}:#{string}`"
        _pattern = require('config').search.pattern pattern
        prev    = filter?.match _pattern

        if string
            if prev
                last = prev[1]
                filter = filter.replace _pattern, input
            else if filter?.length
                filter += input
            else
                filter = input

        else if prev
            filter = filter.replace(_pattern, '')

        @model.set 'filter', filter

        if string? or pattern is 'tag'
            @channel.trigger "filter:#{pattern}", string, last


# Exports Application singleton instance
module.exports = new Application()
