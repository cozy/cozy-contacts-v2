ContactViewModel = require 'views/models/contact'

{indexes, search} = require 'config'

tagRegExp = search.pattern 'tag'
app       = null
scores    = new Map()


Math.median = (array) ->
    sorted = array.sort (a, b) -> a - b
    len = array.length
    sorted[Math.floor array.length / 2]


filter = _.curry (query, model) ->
    if query
        score = model.match query, fullsearch: true
        unless score
            scores.delete model
            return false
        scores.set model, score
    return true


module.exports = class FilteredCollection

    comparator: 'model.attributes.sortedName'

    query: null

    constructor: ->
        app = require 'application'

        @models     = []
        @indexes    = new Map Array::map.call indexes, (char) ->
            vmodels = []
            vmodels.channel = Backbone.Radio.channel "idx.#{char}"
            [char, vmodels]

        @listenTo app.model,
            'change:sort': @reset
            'change:scored': (nil, scored) ->
                @comparator = if scored
                    (a, b) -> (scores.get(b?.model) or 0) - scores.get(a.model)
                else 'model.attributes.sortedName'

        @listenTo app.channel, 'filter:text': @setQuery

        @listenTo app.contacts,
            'reset':             @reset
            'add':               @add
            'remove':            @remove
            'update':            -> @trigger 'update', @
            'change:tags':       (model, value, opts) ->
                vmodel = _.find @models, (vmodel) -> vmodel.model is model
                set = @indexes.get vmodel.getIndexKey()
                set.channel.trigger 'change:tags', vmodel, value, opts
            'change:sortedName': (model) ->
                vmodel = _.find @models, (vmodel) -> vmodel.model is model
                return unless vmodel
                @migrateIndex vmodel


    # Helpers handlers
    # ################
    setQuery: (query) ->
        @query = query

        if query
            res = app.contacts.filter filter @query

            # Reduce to get max score and get a median limit, then excludes all
            # results $lt it.
            maxScore = res.reduce (currentMax, model) ->
                Math.max currentMax, scores.get model
            , 0

            if maxScore > 5
                values  = scores.values()
                _scores = []
                _scores.push score while score = values.next().value

                median = Math.median _scores
                res = res.filter (model) -> scores.get(model) >= median

            toKeep   = @models.filter (vmodel) -> _.includes res, vmodel.model
            toAdd    = _.difference res, toKeep.map (vmodel) -> vmodel.model
            toRemove = _.chain @models
                .difference toKeep
                .map (vmodel) -> vmodel.model
                .value()

            @remove toRemove
            @sort()
            @add toAdd

            @trigger 'update', @
        else
            @reset()


    get: (opts = {}) ->
        base = if opts.index then @indexes.get(opts.index) else @models
        tag  = _.last app.model.get('filter')?.match tagRegExp

        if tag and opts.tagged
            base.filter (vmodel) -> _.includes vmodel.get('tags'), tag
        else
            base


    # Internal models collection handlers
    # ###################################
    reset: ->
        @models = app.contacts
            .filter filter @query
            .map (model) -> new ContactViewModel {}, model: model

        @resetIndexes()

        @trigger 'reset', @


    add: (models) ->
        models = if _.isArray models then _.clone models else [models]

        models.forEach (model) =>
            return unless filter(@query, model)

            vmodel = new ContactViewModel {}, model: model

            idx = _.sortedIndex @models, vmodel, @comparator
            @models.splice idx, 0, vmodel

            @addToIndex vmodel
            @trigger 'add', vmodel, @, {add:true, index: idx}


    remove: (models) ->
        models  = if _.isArray models then _.clone models else [models]
        vmodels = @models.filter (vmodel) -> vmodel.model in models

        vmodels.forEach (vmodel) =>
            _.pull @models, vmodel
            @removeFromIndex vmodel
            @trigger 'remove', vmodel, @


    sort: ->
        @models = _.sortBy @models, @comparator
        @trigger 'sort', @


    # Indexes collections handlers
    # ############################
    resetIndexes: ->
        @indexes.forEach (set) -> set.length = 0
        @models.forEach (vmodel) => @addToIndex vmodel, silent: true
        @indexes.forEach (set) -> set.channel.trigger 'reset', set, {}


    addToIndex: (vmodel, opts = {}) ->
        set = @indexes.get vmodel.getIndexKey()

        return vmodel if _.includes set, vmodel

        idx = _.sortedIndex set, vmodel, @comparator
        set.splice idx, 0, vmodel

        unless opts.silent
            set.channel.trigger 'add', vmodel, set, {add: true, index: idx}
            set.channel.trigger 'update', set

        return set


    removeFromIndex: (vmodel, opts = {}) ->
        if opts.all
            @indexes.forEach (set) ->
                len = set.length
                set = _.pull set, vmodel
                if len isnt set.length and not opts.silent
                    set.channel.trigger 'remove', vmodel, set

        else
            set = @indexes.get(vmodel.getIndexKey())
            _.pull set, vmodel

            unless opts.silent
                set.channel.trigger 'remove', vmodel, set
                set.channel.trigger 'update', set


    migrateIndex: (vmodel) ->
        newSet  = @indexes.get vmodel.getIndexKey()
        return if _.includes newSet, vmodel

        @removeFromIndex vmodel, all: true
        @addToIndex vmodel


_.extend FilteredCollection.prototype, Backbone.Events
