module.exports = class Contact extends Backbone.Model

    idAttribute: '_id'

    urlRoot: 'contacts'

    defaults:
        n:          ';;;;'
        datapoints: []


    parse: (attrs) ->
        delete attrs[key] for key, value of attrs when value is ''

        if (url = attrs.url)
            delete attrs.url
            attrs.datapoints.unshift
                name:  'url'
                type:  'main'
                value: url

        datapoints = new Backbone.Collection()
        datapoints.comparator = 'name'
        datapoints.add attrs.datapoints if attrs.datapoints
        attrs.datapoints = datapoints

        return attrs


    sync: (method, model, options) ->
        options.attrs = model.toJSON()

        datapoints = model.attributes.datapoints.toJSON()
        mainUrl = _.findWhere datapoints, {name: 'url'}

        if mainUrl
            options.attrs.datapoints = _.without datapoints, mainUrl
            options.attrs.url = mainUrl.value

        super
