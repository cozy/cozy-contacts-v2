{Filtered} = BackboneProjections

TagsListener = require 'lib/tags_listener'


class Tags extends Backbone.Collection

    model: require 'models/tag'

    url: 'tags'


    initialize: ->
        @listenToOnce @, 'sync', -> (new TagsListener()).watch @


    parse: (tags) ->
        _.uniq tags, (tag) -> tag.name.toLowerCase()


module.exports = class FilteredTags extends Filtered

    constructor: (@contacts, options = {}) ->
        @updateRefs()
        underlying = new Tags()

        options.filter = (model) =>
            model.get('name') in @refs

        super underlying, options

        @listenTo @contacts, 'add remove reset change:tags', @update


    updateRefs: ->
        @refs = @contacts.chain()
            .map (model) -> model.get 'tags'
            .flatten()
            .uniq()
            .value()


    update: ->
        @updateRefs()
        super
