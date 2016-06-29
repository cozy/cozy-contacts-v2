app = undefined


module.exports = class LabelFilter extends Mn.ItemView

    template: require 'views/templates/labels/filter'

    tagName: 'li'

    ui:
        checkbox: '[data-input="checkbox"]'


    triggers:
        'click @ui.checkbox':
            event:           'tags:bulkupdate'
            preventDefault:  true
            stopPropagation: true


    initialize: ->
        app = require 'application'
        @listenTo app.contacts, 'change:tags': @render


    serializeData: ->
        name     = @model.get 'name'
        pattern  = new RegExp "tag:#{name}", 'i'

        if @options.edit
            selection = app.model.get 'selected'

            contacts = selection.reduce (arr, id) ->
                contact = app.contacts.get id
                if name in contact.get('tags') then arr.concat contact else arr
            , []

            selected = if contacts.length is 0 then false
            else if contacts.length is selection.length then true
            else 'mixed'

        else
            filter   = app.model.get('filter')?.match pattern
            selected = !!filter


        _.extend {}, super,
            selected: selected
            edit: @options.edit
