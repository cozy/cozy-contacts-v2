ContactViewModel = require 'views/models/contact'

inducedOrdering = (collection) ->
    func = (viewModel) ->
        if @comparator.scored
            @filtered[viewModel.model.cid]
        else
            collection.indexOf viewModel.model

    func.induced = true
    func.scored  = false

    return func


module.exports = class ContactViewModelsCollection extends Backbone.Collection

    constructor: (@underlying, options = {}) ->
        app = require 'application'

        @model      = ContactViewModel
        @comparator = options.comparator or inducedOrdering @underlying
        @options    = _.extend {}, @underlying.options, options
        @filtered   = {}

        super @underlying.models, options

        @listenTo @underlying,
            'reset': ->
                @reset @underlying.models
            'remove': (model) ->
                @remove model if @contains model
            'add': (model) ->
                @add model
            'sort': ->
                @sort() if @comparator.induced

        @listenTo app.model,
            'change:scored': (model, value) ->
                @comparator.scored = value
                @sort silent: true unless value

            'change:filter': (model, value) ->
                app     = require 'application'
                pattern = require('config').search.pattern 'text'
                filter  = value.match pattern

                return unless filter

                @filtered = @underlying.models.reduce (memo, model) ->
                    match = model.match filter[1], fullsearch: true
                    memo[model.cid] = match.score * -1 if match
                    return memo
                , {}

                @sort silent: true


    contains: (model) ->
        !!_.find @models, (viewModel) -> viewModel.model is model


    add: (models, options) ->
        models = [models] unless _.isArray models
        models = models.map (model) ->
            new ContactViewModel {}, model: model

        super models, options


    remove: (models, options) ->
        models = [models] unless _.isArray models
        models = models.map (model) =>
            _.find @models, (viewModel) -> viewModel.model is model

        super models, options
