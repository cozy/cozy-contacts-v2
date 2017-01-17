module.exports = class Tag extends Backbone.Model

    urlRoot: 'tags'

    parse: (attrs) ->
        attrs.name = attrs.name.toLowerCase()
        return attrs
