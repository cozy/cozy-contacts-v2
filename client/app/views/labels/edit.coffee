{Filtered}  = BackboneProjections


module.exports = class LabelsAdminToolView extends Mn.CompositeView

    template: require 'views/templates/labels/edit'

    tagName: 'fieldset'


    childViewContainer: 'ul'

    childView: require 'views/labels/filter'

    childViewOptions:
        edit: true

    childEvents:
        'tags:bulkupdate': 'applyBulkTag'


    modelEvents:
        'change:selected': 'render'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    applyBulkTag: (view) ->
        tagName = view.model.get 'name'
        state   = view.ui.checkbox.attr 'aria-checked'

        # Cycle decision from the initial state of the component:
        # - Mixed -> True <=> False
        nextState = if state is "true" then false
        else if state in ["false", "mixed"] then true

        @triggerMethod 'bulk:tag', tagName, nextState
