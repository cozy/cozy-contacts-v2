{Filtered}  = BackboneProjections


module.exports = class Search extends Filtered
    constructor: (underlying, options = {}) ->
        app     = require 'application'
        @filter = app.model.get 'filter'

        options.filter = (model) =>
            if @filter
                [match, tag, ...] = @filter.match /^tag:(\w+)/i
                if tag
                    _.contains model.attributes.tags, tag
                else
                    console.debug 'this is a search'
            else true

        super underlying, options

        @listenTo app.model, 'change:filter', (model, value) ->
            @filter = value
            @update()

    update: ->
        if @filter then @reset @underlying.models.filter @options.filter
        else @reset @underlying.models
