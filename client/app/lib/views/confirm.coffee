module.exports = class ConfirmDialogView extends Mn.ItemView

    template: require './templates/confirm'

    tagName: 'section'

    attributes:
        role: 'alertdialog'
        'aria-busy': false


    ui:
        btn_ok:     'button.ok'
        btn_cancel: 'button.cancel'

    triggers:
        'click @ui.btn_ok':     'confirm:true'
        'click @ui.btn_cancel': 'confirm:false'
        'click button':         'confirm:close'


    onDomRefresh: ->
        setTimeout =>
            @$el.attr 'aria-busy', true
        , 50


    onConfirmClose: ->
        app = require 'application'
        app.layout.alerts.empty()
