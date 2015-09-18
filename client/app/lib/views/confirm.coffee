module.exports = class ConfirmDialogView extends Mn.ItemView

    template: require './templates/confirm'

    tagName: 'section'

    attributes:
        role: 'alertdialog'


    ui:
        btn_ok:     'button.ok'
        btn_cancel: 'button.cancel'

    triggers:
        'click @ui.btn_ok':     'confirm'
        'click @ui.btn_cancel': 'close'


    onConfirm: ->
        @options.success()
        @close()


    onClose: ->
        @close()


    close: ->
        app = require 'application'
        app.layout.alerts.empty()
