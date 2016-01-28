ContactViewModel = require 'views/models/contact'

{indexes} = require 'config'
tagRegExp = require('config').search.pattern 'tag'
app       = null


ordering = (underlying, scores) ->
    fn = (a, b) ->
        if fn.scored
            (scores.get(b?.model) or 0) - scores.get(a.model)
        else
            underlying.indexOf(a.model) - underlying.indexOf(b?.model)

    fn.scored = false
    return fn


module.exports = class FilteredCollection

    constructor: ->
        app = require 'application'

        @sortIdx = if app.model.get('sort') is 'fn' then 0 else 1

        @underlying = app.contacts
        @models     = []
        @scores     = new WeakMap()
        @indexes    = new Map Array::map.call indexes, (char) -> [char, []]
        @query      = null
        @comparator = ordering @underlying, @scores

        @listenTo app.model,
            'change:scored': (nil, scored) => @comparator.scored = scored

        @listenTo app.channel, 'filter:text': @updateQuery

        @listenTo @underlying,
            'reset':  @reset
            'update': -> @trigger 'update', @
            'add':    (model) ->
                @add [model]
            'remove': (model) ->
                @remove @models.filter (vmodel) -> vmodel.model is model
            'sort':   ->
                @sortIdx = if app.model.get('sort') is 'fn' then 0 else 1
                @sort()
                @resetIndexes()


    _filter: (model) =>
        if @query?
            {score} = model.match @query
            unless score
                @scores.delete model
                return false
            @scores.set model, score
        return true


    updateIndex: (vmodel, sorted = true) ->
        initial = vmodel.get('initials')[@sortIdx]?.toLowerCase() or ''
        set = @indexes.get( if /[a-z]/.test initial then initial else '#' )

        return vmodel if _.includes set, vmodel

        if sorted
            idx = _.sortedIndex set, vmodel, @comparator
            set.splice idx, 0, vmodel
        else
            set.push vmodel

        return vmodel


    resetIndexes: ->
        @indexes.forEach (indexArray) ->
            indexArray.length = 0

        @models.forEach (vmodel) =>
            @updateIndex vmodel, false

        @trigger 'reset', @


    updateQuery: (query) ->
        @query = query
        if query
            res = @underlying.filter @_filter

            toKeep   = @models.filter (vmodel) -> _.includes res, vmodel.model
            toRemove = _.difference @models, toKeep
            toAdd    = _.difference res, toKeep.map (vmodel) -> vmodel.model

            @remove toRemove
            @sort()
            @add toAdd
            @trigger 'update', @
        else
            @reset()


    add: (models) ->
        opts =
            add: true
            remove: false
            merge: false

        models.forEach (model) =>
            return unless @_filter model

            vmodel = new ContactViewModel {}, model: model

            idx = _.sortedIndex @models, vmodel, @comparator
            @models.splice idx, 0, vmodel

            @updateIndex vmodel

            @_modelEvents 'add', vmodel, opts


    remove: (vmodels) ->
        vmodels.forEach (vmodel) =>
            return unless _.includes @models, vmodel

            @indexes.forEach (set) -> _.pull set, vmodel
            _.pull @models, vmodel

            @_modelEvents 'remove', vmodel


    sort: ->
        @models.sort @comparator
        @trigger 'sort', @


    reset: ->
        @models = @underlying
            .filter @_filter
            .map (model) -> new ContactViewModel {}, model: model

        @resetIndexes()


    get: (opts = {}) ->
        base = if opts.index then @indexes.get(opts.index) else @models
        tag  = _.last app.model.get('filter')?.match tagRegExp

        if tag and opts.tagged
            base.filter (vmodel) -> _.includes vmodel.get('tags'), tag
        else
            base


    _modelEvents: (eventName, vmodel, opts= {}) ->
        args = [eventName, vmodel, @, opts]
        @trigger.apply vmodel, args
        @trigger.apply @, args


_.extend FilteredCollection.prototype, Backbone.Events
