module.exports = class GroupViewModel extends Backbone.ViewModel

    defaults: ->
        isEmpty: @isEmpty()


    initialize: ->
        @listenTo @compositeCollection,
            'update': -> @set 'isEmpty', @isEmpty()
            'reset':  -> @set 'isEmpty', @isEmpty()


    isEmpty: ->
        not @compositeCollection.length
