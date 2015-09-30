{Filtered}  = BackboneProjections


module.exports = class Search extends Filtered
    constructor: (underlying, options = {}) ->
        app     = require 'application'
        @search = app.model.get 'filter'
        # @_fuzzyIdx = underlying.map @_toFuzzyIdx

        options.filter = @filter

        super underlying, options

        @listenTo app.model, 'change:filter', (model, value) ->
            console.debug value
            @search = value
            @update()


    filter: (model) ->
        return true unless @search

        filters = @search.match /(\w+):(\w+)/gi
        console.debug filters


    # update: ->
    #     if @filter
    #         if @filter.match /^tag:(\w+)/i
    #             @reset @underlying.models.filter @options.filter
    #         else
    #             filter = fuzzy.filter(@filter, @_fuzzyIdx)
    #             @reset _.reduce filter, (memo, idx) =>
    #                 memo.push @underlying.at idx.index
    #                 return memo
    #             , []
    #     else @reset @underlying.models


    # _toFuzzyIdx: (model) ->
    #     attrs = model.attributes
    #
    #     res =
    #         n:     attrs.n.replace(/;/g, ' ').trim()
    #         # tags:  attrs.tags.join ' '
    #         # email: (attrs.datapoints?.chain()
    #         #     .filter (d) -> d.attributes.name is 'email'
    #         #     .map (d) -> d.attributes.value
    #         #     .value()
    #         #     .join ' ')
    #
    #     idx = _.omit res, (value) -> _.isEmpty value
    #     _.values(idx).join ' '
