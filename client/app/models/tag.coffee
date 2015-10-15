module.exports = class Tag extends Backbone.Model

    idAttribute: '_id'


    parse: (attrs) ->
        attrs.name = attrs.name.toLowerCase()
        return attrs
