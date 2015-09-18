module.exports = class ContactEditActionsView extends Mn.ItemView

    tagName: 'dl'

    attributes:
        'aria-haspopup': true
        'aria-expanded': false
        'data-position': 'top left'

    template: require 'views/templates/contacts/components/add-field-dropdown'


    modelEvents:
        'change:bday': 'render'
