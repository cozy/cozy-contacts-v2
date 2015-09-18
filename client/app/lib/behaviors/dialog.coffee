module.exports = class Dialog extends Mn.Behavior

    behaviors:
        Keyboard:
            keymaps:
                '27': 'key:escape'

    ui:
        backdrop: '[role=separator]'
        content:  '[role=contentinfo]'

    triggers:
        'click @ui.backdrop': 'click:backdrop'

    events:
        'click @ui.content': 'detectClickOutside'


    initialize: ->
        @listenTo @view, 'click:backdrop', @close
        @listenTo @view, 'key:escape', @close


    close: ->
        @view.triggerMethod 'dialog:close'


    detectClickOutside: (event) ->
        box = @ui.content[0].getBoundingClientRect()
        if (event.pageX < box.left or event.pageX > box.right) and
        (event.pageY < box.top or event.pageY > box.bottom)
            @close()
