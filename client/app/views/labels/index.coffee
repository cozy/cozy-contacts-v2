{Filtered}  = BackboneProjections

PATTERN = /`tag:([\w\s]+)`/i


module.exports = class LabelsFiltersToolView extends Mn.CompositeView

    template: require 'views/templates/labels'

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
                return false unless app.contacts.length
                !!app.contacts.find (contact) ->
                    _.contains contact.get('tags'), model.get('name')
        @collection.listenTo app.contacts,
            'reset':       @collection.update
            'update':      @collection.update
            'change:tags': @collection.update


    toggleSelected: (model, value) ->
        tag = value?.match(PATTERN)?[1]
        _id = if tag then @collection.find(name: tag).id else 'all'

        @$("[aria-checked]:not([for=filter-#{_id}])")
        .attr 'aria-checked', false

        @$("[for=filter-#{_id}]")
        .attr 'aria-checked', true
