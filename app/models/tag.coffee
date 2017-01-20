module.exports = class Tag extends Backbone.Model


    parse: (attrs) ->
        attrs.name = attrs.name.toLowerCase()
        return attrs
