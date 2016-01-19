CONFIG = require('config').contact


module.exports = class ContactDatapointView extends Mn.ItemView

    tagName: ->
        if @options.cardViewModel.get 'edit' then 'div' else 'li'

    className: 'group'

    attributes: ->
        'data-cid': @model.cid

    template: require 'views/templates/contacts/components/datapoint'


    ui:
        'type': 'input.type'

    events: ->
        if @options.name is 'xtras'
            'keyup @ui.type':  _.debounce @updateType, 250
            'change @ui.type': @updateType


    serializeData: ->
        data = @model.toJSON()
        entity = switch data.name
            when 'social', 'chat' then 'social'
            when 'url'            then 'url'
            else                       'default'

        data.type ?= CONFIG.datapoints.types[entity][0].split(':')[0]

        edit:   @options.cardViewModel.get 'edit'
        ref:    @options.cardViewModel.get 'ref'
        name:   @options.name
        index:  @options.index
        entity: entity
        point:  data


    updateType: (event) ->
        name = @model.get 'name'
        return if name is 'url'

        entity = _.find CONFIG.datapoints.types.social, (type) ->
            type.match new RegExp "^#{event.currentTarget.value.toLowerCase()}"
        if entity
            [..., name] = entity.split ':'
        else
            name = 'other'

        @$(event.currentTarget).siblings('.name').val name
