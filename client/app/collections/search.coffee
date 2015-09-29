{Filtered}  = BackboneProjections


module.exports = class Search extends Filtered
    constructor: (underlying, options = {}) ->
        app     = require 'application'
        @filter = app.model.get 'filter'
        @_fuzzyIdx = underlying.map @_toFuzzyIdx

        options.filter = (model) =>
            if @filter
                [match, tag, ...] = @filter.match /^tag:(\w+)/i
                if tag
                    _.contains model.attributes.tags, tag
                else
                    fuzzy.filter @filter, @_toFuzzyIdx model
            else true

        super underlying, options

        @listenTo app.model, 'change:filter', (model, value) ->
            @filter = value
            @update()


    update: ->
        if @filter
            if @filter.match /^tag:(\w+)/i
                @reset @underlying.models.filter @options.filter
            else
                filter = fuzzy.filter(@filter, @_fuzzyIdx)
                @reset _.reduce filter, (memo, idx) =>
                    memo.push @underlying.at idx.index
                    return memo
                , []
        else @reset @underlying.models


    _toFuzzyIdx: (model) ->
        attrs = model.attributes

        res =
            n:     attrs.n.replace(/;/g, ' ').trim()
            # tags:  attrs.tags.join ' '
            # email: (attrs.datapoints?.chain()
            #     .filter (d) -> d.attributes.name is 'email'
            #     .map (d) -> d.attributes.value
            #     .value()
            #     .join ' ')

        idx = _.omit res, (value) -> _.isEmpty value
        _.values(idx).join ' '
