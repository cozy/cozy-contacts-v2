module.exports = class Contact extends Backbone.Model

    idAttribute: '_id'


    parse: (attrs) ->
        datapoints = new Backbone.Collection()
        datapoints.add attrs.datapoints if attrs.datapoints
        attrs.datapoints = datapoints

        return attrs
