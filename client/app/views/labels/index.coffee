{Filtered}  = BackboneProjections


module.exports = class LabelsFiltersToolView extends Mn.CompositeView

    template: require 'views/templates/labels/index'

    tagName: 'fieldset'


    ui:
        navigate: 'a'

    behaviors:
        Navigator: {}


    childViewContainer: 'ul'

    childView: require 'views/labels/filter'


    initialize: ->
        app = require 'application'
        @listenTo app.channel, 'filter:tag': @toggleSelected


    serializeData: ->
        filter = @model.get('filter') or ''

        data =
            name:     t('tools labels filters all')
            href:     'contacts'
            selected: filter.indexOf('tag:') is -1


    toggleSelected: (tag) ->
        selector = if tag then "[href$='/#{tag}']" else ':first'

        @$ "a:not(#{selector})"
        .attr 'aria-checked', false
        .find('input').prop 'checked', false

        @$ "a#{selector}"
        .attr 'aria-checked', true
        .find('input').prop 'checked', true
