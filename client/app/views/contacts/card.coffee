module.exports = class ContactCardView extends Mn.ItemView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'

    behaviors:
        Dialog: behaviorClass: require 'lib/behaviors/dialog'

    ui:
        edit: '.edit'


    onShow: ->
        @ui.edit.focus()
