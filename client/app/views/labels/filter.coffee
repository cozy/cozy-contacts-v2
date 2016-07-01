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
        # Update component (more specifically its state) when tag is applied on/
        # removed from a contact.
        @listenTo app.contacts, 'change:tags': @render


    serializeData: ->
        name     = @model.get 'name'
        pattern  = new RegExp "tag:#{name}", 'i'

        # @options.edit is passeed from parent view and enable "edit" (aka bulk
        # tagging) mode.
        if @options.edit
            selection = app.model.get 'selected'

            contacts = selection.reduce (arr, id) ->
                contact = app.contacts.get id
                if name in contact.get('tags') then arr.concat contact else arr
            , []

            # Extract state from the selected contact group:
            # - all contacts have the tag > TRUE
            # - no contact have the tag > FALSE
            # - some contact(s) have the tag > 'mixed'
            selected = if contacts.length is 0 then false
            else if contacts.length is selection.length then true
            else 'mixed'

        else
            selected = !!app.model.get('filter')?.match pattern


        _.extend {}, super,
            selected: selected
            edit: @options.edit
