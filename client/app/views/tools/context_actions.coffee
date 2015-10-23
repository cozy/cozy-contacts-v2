module.exports = class DefaultActionsView extends Mn.ItemView

    template: require 'views/templates/tools/context_actions'

    tagName: 'fieldset'


    ui:
        selectAll:  '[formaction="select/all"]'
        selectNone: '[formaction="select/none"]'


    triggers:
        'click @ui.selectAll':  'select:all'
        'click @ui.selectNone': 'select:none'

    modelEvents:
        'change:selected': (nil, selected) -> @render() if selected.length


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents
