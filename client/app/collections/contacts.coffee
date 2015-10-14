comparator = (a, b) ->
    a = a.get('n').split ';'
    b = b.get('n').split ';'

    index = switch @comparator.sort
        when 'gn' then 0
        when 'fn' then 1
        else           0

    a[index].localeCompare b[index]


module.exports = class Contacts extends Backbone.Collection

    model: require 'models/contact'

    url: 'contacts'


    initialize: ->
        app = require('application')

        @comparator      = comparator
        @comparator.sort = app.model.get 'sort'

        @listenTo app.model, 'change:sort', (appViewModel, sort)->
            @comparator.sort = sort
            @sort()
