module.exports = class ContactRow extends Mn.ItemView

    template: require 'views/templates/contacts/row'

    tagName: 'li'

    attributes:
        role: 'listitem'


    modelEvents:
        'change': 'render'


    serializeData: ->
        app        = require 'application'
        filter     = (app.model.get('filter') or '').match /text:(\w+)/i
        formatOpts =
            pre: '<b>'
            post: '</b>'

        if filter
            match = @model.match filter[1],
                pre: '<span class="search">'
                post: '</span>'
                format: formatOpts
            fullname = match.rendered
        else
            fullname = @model.toString formatOpts

        _.extend {}, super(), fullname: fullname
        # filter = require('application').model.get 'filter'
        #
        # if filter and not filter.match /^tag:/i
        #     data.name = _.mapObject data.name, (value) ->
        #         result = fuzzy.match filter, value,
        #             pre: '<span class="search">'
        #             post: '</span>'
        #         return result?.rendered or value
        #
        #     console.debug data.name
