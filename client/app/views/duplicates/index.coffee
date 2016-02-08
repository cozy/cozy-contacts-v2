Duplicates = require 'collections/duplicates'

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class DuplicatesView extends Mn.CompositeView

    template: require 'views/templates/duplicates'

    tagName: 'section'

    className: 'duplicates'

    attributes:
        role: 'dialog'


    childViewContainer: '[role="grid"]'

    childView: require 'views/duplicates/row'

    templateHelpers: ->
        size: @toMerge.size()


    behaviors:
        Dialog: {}


    collectionEvents:
        'contacts:merge': 'render'

    render: ->
        super
        $($('nav a').get(1)).attr 'aria-busy', false


    initialize: ->
        {contacts} = require 'application'

        # Generate duplicates list.
        @collection = new Duplicates null, collection: contacts
        @toMerge = new BackboneProjections.Filtered @collection,
            filter: (merge) ->
                merge.isMergeable()
        @bindEntityEvents @collection, @getOption 'collectionEvents'

