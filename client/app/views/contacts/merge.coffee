t = require 'lib/i18n'

module.exports = class MergeView extends Mn.ItemView

    template: require 'views/templates/contacts/merge'

    tagName: 'section'

    className: 'merge'

    attributes:
        role: 'alertdialog'


    behaviors: ->
        Navigator: {}
        Dialog:    {}
        Form:      {}

    ui:
        submit:   '[type=submit]'
        cancel:   '.cancel'
        inputs:   'input'


    events:
        'click @ui.cancel': 'onClose'


    initialize: ->
        # TODO : howto marionette fashion?
        @listenTo @, 'form:submit', @onSubmit.bind @

        if @model
            Mn.bindEntityEvents @model, @, @model.viewEvents

        # TODO Stubs !
        else
            app = require 'application'
            # Generate duplicates list.
            CompareContacts = require "lib/compare_contacts"
            MergeViewModel = require('views/models/merge')
            @model = new MergeViewModel()

            toMerge = CompareContacts.findSimilars(app.contacts.toJSON())[0]

            if toMerge?
                toMerge = toMerge.map (contact) ->
                    console.log contact
                    return app.contacts.get(contact.id)

                @model.set 'toMerge', toMerge
                Mn.bindEntityEvents @model, @, @model.viewEvents
                @mergeOptions = @model.buildMergeOptions()

            else
                return


    serializeData: ->
        return model: @model.toJSON()


    onSubmit: ->
        @model.merge =>
            @onClose()


    onClose: ->
        app = require 'application'
        app.layout.alerts.empty()

