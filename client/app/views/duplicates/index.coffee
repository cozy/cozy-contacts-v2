Duplicates = require 'collections/duplicates'

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class DuplicatesView extends Mn.CompositeView

    template: require 'views/templates/duplicates'

    tagName: 'section'

    className: 'duplicates'

    attributes:
        role: 'dialog'


    childViewContainer: '[role=grid]'

    childView: require 'views/duplicates/row'

    templateHelpers: ->
        size: @toMerge.size()


    behaviors:
        Dialog: {}

    ui:
        'mergeAll': '.mergeall'


    events:
        'click @ui.mergeAll': 'mergeAll'


    initialize: ->
        app = require 'application'

        # Generate duplicates list.
        @collection = new Duplicates()
        @collection.findDuplicates app.contacts

        @toMerge = new BackboneProjections.Filtered @collection,
            filter: (merge) -> merge.isMergeable()

        @listenTo @toMerge, 'all', =>
            @$('.mergeallcount').text @toMerge.size()


    # TODO: NO TEMPLATING IN VIEWS
    emptyView: Backbone.Marionette.ItemView.extend
        template: "<p>#{t('duplicates empty')}</p>"


    mergeAll: ->
        # Block any input during mergeall.
        @$('button,input').attr 'disabled', 'disabled'
        # Hack to help firefox to display the spinner.
        _.defer => @ui.mergeAll.attr 'aria-busy', 'true'

        async.eachSeries @toMerge.toArray(), (merge, callback) =>
            # After a Mergerow::merge, the merge ViewModel always trigger a
            # contacts:merge event:
            # * when merge went well
            # * when an error occurs in merge (error as second arg)
            # * when the user cancel the merge (abort error as second arg).
            @listenTo merge, 'contacts:merge', (model, err) ->
                # Let the UI breath.
                # TODO: replace with a cleaner setImmediate call.
                _.defer callback, err

            @children.findByModel(merge).merge()

        , (err) =>
            @$('button,input').removeAttr 'disabled'
            @ui.mergeAll.attr 'aria-busy', 'false'

            console.error err if err
