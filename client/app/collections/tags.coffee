module.exports = class Tags extends Backbone.Collection

    model: require 'models/tag'

    url: 'tags'


    parse: (tags) ->
        _.uniq tags, (tag) -> tag.name.toLowerCase()
