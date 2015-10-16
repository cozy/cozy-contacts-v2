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

    emptyView: Backbone.Marionette.ItemView.extend
        template: "<p>#{t('duplicates empty')}</p>"

    templateHelpers: ->
        return size: @toMerge.size()

    behaviors: ->
        Dialog:    {}

    events:
        'click [type=submit]': 'mergeAll'


    initialize: ->
        app = require 'application'

        # Generate duplicates list.
        @collection = new Duplicates()
        @collection.findDuplicates app.contacts

        @toMerge = new BackboneProjections.Filtered @collection,
            filter: (merge) -> merge.isMergeable()

        @listenTo @toMerge, 'all', =>

            @$('.mergeallcount').text @toMerge.size()


    mergeAll: ->
        # Block any input during mergeall.
        @$('button,input').attr 'disabled', 'disabled'

        async.eachSeries @toMerge.toArray(), (merge, callback) =>
            # After a Mergerow::merge, a the merge ViewModel always trigger a
            # contacts:merge event:
            # * when merge went well
            # * when an error occurs inn merge (error as second arg)
            # * when the user cancel the merge (abort error as second arg).
            @listenTo merge, 'contacts:merge', (model, err) ->
                # Let the UI breath.
                # TODO: replace with a cleaner setImmediate call.
                setTimeout ->
                    callback err
                , 1

            @children.findByModel(merge).merge()

        , (err) =>
            @$('button,input').removeAttr 'disabled'
