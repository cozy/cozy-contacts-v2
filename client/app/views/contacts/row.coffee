PATTERN = require('config').search.pattern 'text'


module.exports = class ContactRow extends Mn.ItemView

    template: require 'views/templates/contacts/row'

    tagName: 'li'

    attributes:
        role: 'row'


    modelEvents:
        'change': 'render'
        'sync':   'render'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:selected', @refreshChecked


    serializeData: ->
        app        = require 'application'
        filter     = app.model.get('filter')?.match PATTERN
        formatOpts =
            pre: '<b>'
            post: '</b>'

        if filter
            match = @model.match filter[1],
                pre: '<span class="search">'
                post: '</span>'
                format: formatOpts
            fullname = match?.rendered
        else
            fullname = @model.toString formatOpts

        _.extend {}, super(),
            fullname: fullname
            selected: @model.id in app.model.get 'selected'


    refreshChecked: (appViewModel, selected)->
        @$('[type=checkbox]').prop 'checked', @model.id in selected
