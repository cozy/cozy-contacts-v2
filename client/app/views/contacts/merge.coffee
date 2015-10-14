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

    modelEvents:
        'contacts:merge': 'onClose'

    events:
        'click @ui.cancel': 'onClose'


    initialize: ->
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
                    return app.contacts.get(contact.id)

                @model.set 'toMerge', toMerge
                Mn.bindEntityEvents @model, @, @model.viewEvents
                @mergeOptions = @model.buildMergeOptions()

            else
                return


    serializeData: ->
        return model: @model.toJSON()


    onFormSubmit: ->
        @model.merge()


    onClose: ->
        require('application').layout.alerts.empty()
