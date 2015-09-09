module.exports = class ContactCardView extends Mn.ItemView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'

    behaviors:
        Navigator: behaviorClass: require 'lib/behaviors/navigator'
        Dialog:    behaviorClass: require 'lib/behaviors/dialog'
        Form:      behaviorClass: require 'lib/behaviors/form'

    ui:
        navigate: '[href^=contacts]'
        edit:     '.edit'
        submit:   '.save'
        inputs:   'input, textarea'
        add:      '.add button'
        autoAdd:  '.auto .value'

    modelEvents:
        'change:edit': 'render'


    initialize: ->
        @model.attachViewEvents @


    onShow: ->
        @ui.edit.focus()
