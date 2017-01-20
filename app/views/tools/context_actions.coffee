module.exports = class DefaultActionsView extends Mn.ItemView

    template: require 'views/templates/tools/context_actions'

    tagName: 'fieldset'


    behaviors: ->
        Confirm:
            triggers:
                'click @ui.delete': @_deleteModalCfg


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
        'click @ui.merge':    'bulk:merge'


    modelEvents:
        'change:selected': (nil, selected) -> @render() if selected.length


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    # Build configuration required to display a proper modal. This modal will
    # ask the user for a confirmation of deletion.
    # To display this modal, we rely on the Marionnette behavior called
    # Confirm.
    _deleteModalCfg: =>
        opts = smart_count: @model.get('selected').length
        return behaviorConfig =
            event:      'bulk:delete'
            title:      t 'bulk confirm delete title', opts
            message:    t 'bulk confirm delete message', opts
            btn_ok:     t 'bulk confirm delete ok'
            btn_cancel: t 'bulk confirm delete cancel'
            end_event:  'bulk:delete:done'

