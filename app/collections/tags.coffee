###
Tags Collection

Tags can be shared between apps in the Cozy DS, so we need a simple way to
sometimes only use a projections of tags (those only used by Contacts docs). We
so create a standard `TagsCollection` that will be used as an underlying
collection for the Filtered projection.
###

{Filtered} = BackboneProjections

TagsListener = require 'lib/tags_listener'


class Tags extends Backbone.Collection

    model: require 'models/tag'

    url: 'tags'


    initialize: ->
        @listenToOnce @, 'sync', -> (new TagsListener()).watch @

    # We convert all tags to lowercase and remove duplicates at pers time
    parse: (tags) ->
        _.uniq tags, (tag) -> tag.name.toLowerCase()


# Export TagsCollection is the Contacts aware projection. All tags Collection
# can be accessed at `underlying` property.
module.exports = class FilteredTags extends Filtered

    constructor: (@contacts, options = {}) ->
        @updateRefs()
        underlying = new Tags()

        options.filter = (model) =>
            model.get('name') in @refs

        super underlying, options

        @listenTo @contacts, 'add remove reset change:tags', @update


    # @refs are simple array of tag in use in all contacts docs.
    #
    # @updateRefs is responsible to walk accross all contacts and extract and
    # concact tags.
    updateRefs: ->
        @refs = @contacts.chain()
            .map (model) -> model.get 'tags'
            .flatten()
            .uniq()
            .value()


    update: ->
        @updateRefs()
        super
