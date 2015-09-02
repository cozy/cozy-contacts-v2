module.exports = class ContactCardView extends Mn.ItemView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'

    behaviors:
        Navigator: behaviorClass: require 'lib/behaviors/navigator'
        Dialog: behaviorClass: require 'lib/behaviors/dialog'

    ui:
        navigate: '[href^=contacts]'
        edit: '.edit'

    modelEvents:
        'change:edit': 'render'


    onShow: ->
        @ui.edit.focus()
