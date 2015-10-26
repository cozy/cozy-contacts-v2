module.exports = class DefaultActionsView extends Mn.ItemView

    template: require 'views/templates/tools/context_actions'

    tagName: 'fieldset'


    behaviors: ->
        Confirm: triggers: 'click @ui.delete': @_deleteModalCfg


    ui:
        select:     '[formaction="select/all"]'
        unselect:   '[formaction="select/none"]'
        merge:      '[formaction="contacts/merge"]'
        export:     '[formaction="contacts/export"]'
        delete:     '[formaction="contacts/delete"]'


    triggers:
        'click @ui.select':   'select:all'
        'click @ui.unselect': 'select:none'
        'click @ui.export':   'bulk:export'

    modelEvents:
        'change:selected': (nil, selected) -> @render() if selected.length


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    _deleteModalCfg: =>
        opts = smart_count: @model.get('selected').length
        return cfg =
            event:      'bulk:delete'
            title:      t 'bulk confirm delete title', opts
            message:    t 'bulk confirm delete message', opts
            btn_ok:     t 'bulk confirm delete ok'
            btn_cancel: t 'bulk confirm delete cancel'
