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
        'contacts:update': 'updateBulkSelection'


    initialize: ->
        app = require 'application'

        # TODO : handle mixed selection
        # TODO : sort tags (top = selected tags)

        @setSelected()
        @collection = new SelectCollection app.tags,
            filter: (model) =>
                if (filter = app.contacts.tagMap[model.get('name')]?)
                    value = _.contains @getSelected(), model.get('name')
                    model.set 'selected', value, silent: true
                filter


    setSelected: ->
        app = require 'application'
        result = []
        selected = @model.get 'selected'
        app.filtered.get(tagged: true).map (contact) ->
            if _.contains selected, contact.id
                result.push contact.get('tags')
        _selected = _.compact _.flatten result
        _selected


    getSelected: ->
        _selected


    updateBulkSelection: (event, tag) ->
        model = @collection.findWhere({ id: tag.id })
        model.set({ selected: tag.selected })
