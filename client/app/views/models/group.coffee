module.exports = class GroupViewModel extends Backbone.ViewModel

    map:
        isEmpty: 'isEmpty'


    isEmpty: ->
        not @compositeCollection.length
