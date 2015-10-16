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
        'click @ui.cancel': 'onCancel'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        return model: @model.toJSON()


    onFormSubmit: ->
        @model.merge()
        # Close directly here, to give reactivity feeling.
        @onClose()


    onCancel: ->
        # Trigger merge procedure ended, with 'abort' error.
        @model.trigger 'contacts:merge', @model, "abort"
        @onClose()


    onClose: ->
        require('application').layout.alerts.empty()
