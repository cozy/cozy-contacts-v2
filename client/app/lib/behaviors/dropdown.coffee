module.exports = class DropdownBehavior extends Mn.Behavior

    ui:
        trigger: '[aria-haspopup="true"] > :first-child'


    events:
        'click @ui.trigger': 'toggleExpand'
        'click':             'closeAll'


    toggleExpand: (event) ->
        event.stopPropagation()

        el = @$(event.currentTarget).parent '[aria-haspopup]'
        @closeAll el
        el.attr 'aria-expanded', el.attr('aria-expanded') isnt 'true'


    closeAll: (el) ->
        @$('[aria-haspopup="true"]').not(el).attr('aria-expanded', false)
