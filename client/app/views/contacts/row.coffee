module.exports = class ContactRow extends Mn.ItemView

    template: require 'views/templates/contacts/row'

    tagName: 'li'

    attributes:
        role: 'listitem'


    modelEvents:
        'change': 'render'


    serializeData: ->
        data = _.extend {}, super(),
            fullname: @model.toString
                pre: '<b>'
                post: '</b>'
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
