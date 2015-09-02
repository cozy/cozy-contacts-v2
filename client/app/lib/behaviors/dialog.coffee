module.exports = class Modal extends Mn.Behavior

    behaviors:
        Keyboard:
            behaviorClass: require 'lib/behaviors/keyboard'
            keymaps:
                '27': 'key:escape'

    ui:
        backdrop: '[role=separator]'

    triggers:
        'click @ui.backdrop': 'click:backdrop'


    initialize: ->
        @listenTo @view, 'click:backdrop', @close
        @listenTo @view, 'key:escape', @close


    close: ->
        @view.triggerMethod 'dialog:close'
