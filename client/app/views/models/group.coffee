module.exports = class GroupViewModel extends Backbone.ViewModel

    defaults: ->
        isEmpty: @isEmpty()


    initialize: ->
        @compositeCollection.on 'add remove', => @set 'isEmpty', @isEmpty()


    isEmpty: ->
        not @compositeCollection.length
