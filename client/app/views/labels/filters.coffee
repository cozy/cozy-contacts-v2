{Filtered}  = BackboneProjections


module.exports = class LabelsFiltersToolView extends Mn.CompositeView

    template: require 'views/templates/labels/filters'

    tagName: 'fieldset'


    ui:
        navigate: 'a'

    behaviors:
        Navigator: {}


    childViewContainer: 'ul'

    childView: require 'views/labels/filter'


    modelEvents:
        'change:filter': 'toggleSelected'


    initialize: ->
        app     = require 'application'
        @collection = new Filtered app.tags,
            filter: (model) ->
                return unless app.contacts.length
                contacts = app.contacts.find (contact) ->
                    _.contains contact.attributes.tags, model.attributes.name
                !!contacts
        @collection.listenTo app.contacts,
            'reset':  @collection.update
            'update': @collection.update


    toggleSelected: (model, value) ->
        if value
            [match, tag, ...] = value.match /^tag:(\w+)/i
            _ref = @collection.find(name: tag)
        else
            _ref = null
        
        _id = if _ref then _ref.get '_id' else 'all'

        @$("[aria-checked]:not([for=filter-#{_id}])")
        .attr 'aria-checked', false

        @$("[for=filter-#{_id}]")
        .attr 'aria-checked', true
