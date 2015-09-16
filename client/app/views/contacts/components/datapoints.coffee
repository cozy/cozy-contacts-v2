ContactDatapointView = require 'views/contacts/components/datapoint'


module.exports = class ContactDatapointsView extends Mn.CollectionView

    tagName: ->
        if @options.cardViewModel.get 'edit' then 'fieldset' else 'ul'


    behaviors:
        Form: {}

    ui: ->
        (ui = {})['inputs'] = ':input:not(button)'
        ui.autoAdd = '.value' unless @options.name is 'xtras'
        return ui


    childView: ContactDatapointView

    childViewOptions: (model, index)->
        _.extend _.pick(@options, 'name', 'cardViewModel'), index: index


    initialize: (options) ->
        @on 'form:addfield', @addEmptyField
        @on 'form:updatefield', @updateFields

        if options.cardViewModel.get 'edit'
            @collection = new Backbone.Collection options.collection.models
            @addEmptyField() unless @options.name is 'xtras'


    addEmptyField: (name) ->
        @collection.add
            type:  undefined
            value: ''
            name:  name or @options.name


    updateFields: (event) ->
        $item = @$(event.currentTarget).parents '[data-cid]'
        model = @collection.get $item.data 'cid'
        attrs = _.reduce $item.find(':input').serializeArray(), (memo, input) ->
            memo[_.last(input.name.split '.')] = input.value
            return memo
        , {}
        model.set attrs


    getDatapoints: ->
        @collection.filter (model) -> model.get('value') isnt ''
