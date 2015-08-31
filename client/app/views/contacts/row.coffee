
module.exports = class ContactRow extends Mn.ItemView

    template: require 'views/templates/contacts/row'

    tagName: 'li'

    attributes:
        role: 'row'

    ui:
        navigate: 'a[href^=contacts]'

    behaviors:
        Navigator:
            behaviorClass: require 'behaviors/navigator'
