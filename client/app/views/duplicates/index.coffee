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

    ui:
        'mergeAll': '.mergeall'


    events:
        'click @ui.mergeAll': 'mergeAll'

    collectionEvents:
        'contacts:merge': 'render'


    initialize: ->
        app = require 'application'

        # Generate duplicates list.
        @collection = new Duplicates null, collection: app.contacts
        @toMerge = new BackboneProjections.Filtered @collection,
            filter: (merge) -> merge.isMergeable()

        @bindEntityEvents @collection, @getOption 'collectionEvents'


    mergeAll: ->
        # Block any input during mergeall.
        @$('button,input').prop 'disabled', true
        # Hack to help firefox to display the spinner.
        _.defer => @ui.mergeAll.attr 'aria-busy', true

        async.eachSeries @toMerge.toArray(), (merge, callback) =>
            # After a Mergerow::merge, the merge ViewModel always trigger a
            # contacts:merge event:
            # * when merge went well
            # * when an error occurs in merge (error as second arg)
            # * when the user cancel the merge (abort error as second arg).
            @listenTo merge, 'contacts:merge', (model, err) ->
                _.defer callback, err

            @children.findByModel(merge).merge()

        , (err) =>
            @$('button,input').removeAttr 'disabled'
            @ui.mergeAll.attr 'aria-busy', 'false'

            console.error err if err
