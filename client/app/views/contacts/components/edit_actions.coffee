module.exports = class ContactEditActionsView extends Mn.ItemView

    tagName: 'dl'

    className: 'dropdown'

    template: require 'views/templates/contacts/components/add-field-dropdown'

    modelEvents:
        'change:bday': 'render'
