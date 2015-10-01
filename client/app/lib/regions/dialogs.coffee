module.exports = class Dialogs extends Mn.Region

    toggleDialogs: (visible) ->
        visible ?= @$el.attr('aria-hidden') isnt 'true'
        @$el.attr 'aria-hidden', not visible


    onShow: ->
        @toggleDialogs true


    onBeforeEmpty: ->
        @toggleDialogs false
