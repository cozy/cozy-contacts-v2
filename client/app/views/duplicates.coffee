Duplicates = require 'collections/duplicates'

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class DuplicatesView extends Mn.CompositeView

    template: require 'views/templates/duplicates'

    tagName: 'section'

    className: 'duplicates'

    attributes:
        role: 'dialog'

    childViewContainer: 'ul'

    childView: require 'views/mergerow'

    templateHelpers: ->
        return size: @collection.size()

    behaviors: ->
        Dialog:    {}

    events:
        'click [type=submit]': 'mergeAll'


    initialize: ->
        app = require 'application'

        # Generate duplicates list.
        @collection = new Duplicates()
        @collection.findDuplicates app.contacts


    mergeAll: ->
        # Register on merged event, to perform merge on next item ;
        # merge current item.
        mergeStep = (model) =>
            index = 1 + @collection.indexOf model
            if index < @collection.size()
                @listenTo @children.findByModel(model), 'end', =>
                    mergeStep @collection.at index

            @children.findByModel(model).merge()

        mergeStep @collection.first()
