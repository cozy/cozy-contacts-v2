{Filtered}  = BackboneProjections

PATTERN = require('config').search.pattern 'tag'


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
        _ref = if tag then @collection.find(name: tag).id else 'all'

        @$ "a:not([data-id=#{_ref}])"
        .attr 'aria-checked', false
        .find('input').prop 'checked', false

        @$("a[data-id=#{_ref}]")
        .attr 'aria-checked', true
        .find('input').prop 'checked', true
