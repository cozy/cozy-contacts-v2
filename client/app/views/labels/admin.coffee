{Filtered, Sorted}  = BackboneProjections

_selected = []

class SelectCollection extends Filtered
    # constructor: (underlying, subtrahend, options = {}) ->
    #     # options.filter = (model) -> not subtrahend.contains(model)
    #
    #     console.log 'new SelectCollection', underlying, options
    #     super underlying, options

module.exports = class LabelsAdminToolView extends Mn.CompositeView

    template: require 'views/templates/labels/admin'

    tagName: 'fieldset'


    behaviors:
        Navigator: {}


    childViewContainer: 'ul'

    childView: require 'views/labels/select'


    childEvents:
        'label:update': 'updateSelection'


    modelEvents:
        'change:selected': 'updateAll'


    initialize: ->
        app = require 'application'

        # TODO : sort tags (top = selected tags)
        @collection = new SelectCollection app.tags,
            filter: (model) =>
                app.contacts.tagMap[model.get('name')]?
        @listenTo @collection, 'change', @render

    select: (model) =>
        # TODO : handle mixed selection
        value = _.contains @getSelected(), model.get('name')
        model.set 'selected', value

    # Define selected labels
    setSelected: ->
        app = require 'application'
        result = []
        selected = @model.get 'selected'
        result = app.filtered.get(tagged: true).map (contact) ->
            filter = _.contains selected, contact.id
            return if filter then contact.get('tags') else false
        _selected = _.compact _.flatten result
        _selected


    getSelected: ->
        _selected

    updateAll: ->
        @setSelected()
        @collection.each (model) =>
            @select model

    updateSelection: (event, tag) ->
        model = @collection.findWhere({ id: tag.id })
        model.set({ selected: tag.selected })

        # Update tags into contactList
        @triggerMethod 'label:change', model
