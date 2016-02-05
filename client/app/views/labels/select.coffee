module.exports = class LabelSelect extends Mn.ItemView

    template: require 'views/templates/labels/select'

    tagName: 'li'

    events:
        'change input[type="checkbox"]': 'select'


    # FIXME : should move this elsewhere?
    select: (event) ->
        @triggerMethod 'contacts:update',
            id: event.currentTarget.id
            selected: !!event.currentTarget.checked
