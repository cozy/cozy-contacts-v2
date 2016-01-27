{Filtered}  = BackboneProjections


module.exports = class LabelsFiltersToolView extends Mn.CompositeView

    template: require 'views/templates/labels'

    tagName: 'fieldset'


    ui:
        navigate: 'a'

    behaviors:
        Navigator: {}


    childViewContainer: 'ul'

    childView: require 'views/labels/filter'


    initialize: ->
        app = require 'application'

        # Tag collection filtering is based on the tag map built at the contact
        # collection level. It avoids to do too many checkings while looking
        # for available tags.
        @collection = new Filtered app.tags,
            filter: (model) ->
                app.contacts.tagMap[model.get('name')]?

        @collection.listenTo app.contacts,
            'reset':       @collection.update
            'update':      @collection.update
            'change:tags': @collection.update

        @listenTo app.vent, 'filter:tag': @toggleSelected


    toggleSelected: (tag) ->
        selector = if tag then "[href$='/#{tag}']" else ':first'

        @$ "a:not(#{selector})"
        .attr 'aria-checked', false
        .find('input').prop 'checked', false

        @$ "a#{selector}"
        .attr 'aria-checked', true
        .find('input').prop 'checked', true
