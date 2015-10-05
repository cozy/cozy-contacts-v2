{Filtered}  = BackboneProjections


module.exports = class Search extends Filtered
    constructor: (underlying, options = {}) ->
        app     = require 'application'
        @search = app.model.get 'filter'

        options.filter = @filter

        super underlying, options

        @listenTo app.model, 'change:filter', (model, value) ->
            @search = value
            @update()


    filter: (model) =>
        return true unless @search

        filters = @search.match /(\w+):(\w+)/gi
        filters.reduce (memo, filter) ->
            [pattern, string] = filter.split ':'
            pass = switch pattern
                when 'tag' then _.contains model.attributes.tags, string
                when 'text' then model.match string
                else true
            memo = false unless pass
            return memo
        , true


    update: ->
        if @filter then @reset @underlying.models.filter @options.filter
        else @reset @underlying.models
