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


    # serializeData is by default a call .toJSON on the model and the result is
    # passed to the template that renders the data.
    serializeData: ->
        data = @model.toJSON()

        # Entity is used for display purposes: for instance this variable
        # determines the text that is shown in the placeholders for the
        # elements selected from the "other information" dropdown list.
        entity = switch data.name
            when 'social', 'chat' then 'social'

            # So that we are still compliant to the vCard RFC we need to
            # convert the data.name from 'share' to 'url' when we store it.
            # Once this is done we still need to set their entity to 'share'.
            when 'url'
                if data.mediatype? and data.mediatype.search 'cloud' != -1
                    'share'
                else
                    'url'

            # When the datapoint is created the data.name is already set to
            # 'share'
            when 'share'          then 'share'

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
        return if name in ['url', 'share']

        entity = _.find CONFIG.datapoints.types.social, (type) ->
            type.match new RegExp "^#{event.currentTarget.value.toLowerCase()}"
        if entity
            [..., name] = entity.split ':'
        else
            name = 'other'

        @$(event.currentTarget).siblings('.name').val name
