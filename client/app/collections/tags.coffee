module.exports = class Tags extends Backbone.Collection

    model: require 'models/contact'

    url: 'tags'


    parse: (response) ->
        res = _.uniq response, true, (model) -> model.name.toLowerCase()
