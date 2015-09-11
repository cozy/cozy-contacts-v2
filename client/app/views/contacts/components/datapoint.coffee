module.exports = class ContactDatapointView extends Mn.ItemView

    tagName: ->
        if @options.edit then 'div' else 'li'

    className: 'group'

    attributes: ->
        'data-cid': @model.cid

    template: require 'views/templates/contacts/components/datapoint'


    serializeData: ->
        entity = switch @options.name
            when 'im', 'chat' then 'social'
            when 'url'        then 'link'
            else                   'default'

        data = super
        data.type ?= @options.cardViewModel.get('lists')[entity][0]

        edit:   @options.cardViewModel.get 'edit'
        ref:    @options.cardViewModel.get 'ref'
        name:   @options.name
        index:  @options.index
        entity: entity
        point:  data
