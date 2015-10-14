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
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        return model: @model.toJSON()


    onFormSubmit: ->
        @model.merge()


    onClose: ->
        require('application').layout.alerts.empty()
