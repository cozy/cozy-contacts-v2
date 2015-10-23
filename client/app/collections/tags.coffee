TagsListener = require 'lib/tags_listener'


module.exports = class Tags extends Backbone.Collection

    model: require 'models/tag'

    url: 'tags'


    initialize: ->
        @listenToOnce @, 'sync', -> (new TagsListener()).watch @


    parse: (tags) ->
        _.uniq tags, (tag) -> tag.name.toLowerCase()
