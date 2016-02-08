{Filtered, Sorted}  = BackboneProjections

module.exports = class LabelsAdminToolView extends Mn.CompositeView

    template: require 'views/templates/labels/admin'

    tagName: 'fieldset'


    behaviors:
        Navigator: {}


    childViewContainer: 'ul'

    childView: require 'views/labels/select'


    childEvents:
        'label:update': 'changeSelection'


    modelEvents:
        'change:selected': 'updateSelection'


    select: (model, models) =>
        # TODO : handle mixed selection
        value = _.contains models, model.get('name')
        model.set {'selected': value}, {'silent': true}


    # Define selected labels
    getSelection: ->
        value = @model.get 'selected'

        app = require 'application'
        result = app.filtered.get(tagged: true).map (contact) ->
            filter = _.contains value, contact.id
            return if filter then contact.get('tags') else false

        _.uniq _.compact _.flatten result


    updateSelection: ->
        unless @collection
            # TODO : sort tags (top = selected tags)
            app = require 'application'
            @collection = new Filtered app.tags,
                filter: (model) ->
                    console.log 'filter', model
                    app.contacts.tagMap[model.get('name')]?

        # Upgrade selected values
        selection = @getSelection()
        @collection.each (model) =>
            @select model, selection

        # Display updated tagsList
        @render()


    changeSelection: (event, tag) ->
        model = @collection.findWhere 'id': tag.id
        model.set 'selected', tag.selected

        # Should Update tags into contactList
        @triggerMethod 'label:change', model
