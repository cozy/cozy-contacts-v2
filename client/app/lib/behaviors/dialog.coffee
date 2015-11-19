module.exports = class Dialog extends Mn.Behavior

    behaviors:
        Keyboard:
            keymaps:
                '27': 'key:escape'

    ui:
        backdrop: '[role="separator"]'
        content:  '[role="contentinfo"]'

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
        # Chrome consider pageX and pageY = 0 when clicking on components such
        # <select>. So we perform the outside test only if pageX and pageY > 0.
        return unless event.pageX or event.pageY

        box = @ui.content[0].getBoundingClientRect()
        inW = event.pageX < box.left or event.pageX > box.right
        inH = event.pageY < box.top or event.pageY > box.bottom
        @close() if inH and inW
