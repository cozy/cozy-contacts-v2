t = require 'lib/i18n'

module.exports = class MergeView extends Mn.ItemView

    template: require 'views/templates/contacts/merge'

    tagName: 'section'

    className: 'merge'

    attributes:
        role: 'alertdialog'

    behaviors:
        Dialog:    {}
        Form:      {}

    ui:
        formSubmit: '[type="submit"]'
        formInputs: 'input'
        cancel: '.cancel'

    modelEvents:
        'contacts:merge': 'onClose'

    events:
        'click @ui.cancel': 'onCancel'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        return model: @model.toJSON()


    onDomRefresh: ->
        _.defer => @$el.attr('aria-busy', true)


    onFormSubmit: ->
        @model.merge()
        # Close directly here, to give reactivity feeling.
        @onClose()


    onCancel: ->
        # Trigger merge procedure ended, with 'abort' error.
        @model.trigger 'contacts:merge', @model, "abort"


    onClose: ->
        require('application').layout.alerts.empty()
