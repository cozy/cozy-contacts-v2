DatapointsView  = require 'views/contacts/components/datapoints'
EditActionsView = require 'views/contacts/components/edit_actions'


module.exports = class ContactCardView extends Mn.LayoutView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'


    behaviors:
        Navigator: behaviorClass: require 'lib/behaviors/navigator'
        Dialog:    behaviorClass: require 'lib/behaviors/dialog'
        Form:      behaviorClass: require 'lib/behaviors/form'

    ui:
        navigate: '[href^=contacts]'
        edit:     '.edit'
        submit:   '[type=submit]'
        inputs:   'input, textarea'
        add:      '.add button'

    regions:
        actions: '.actions'


    modelEvents:
        'change:edit':     'render'
        'change:initials': 'updateInitials'


    initialize: ->
        @model.attachViewEvents @
        @on 'form:submit', @syncDatapoints


    onRender: ->
        @$('[data-type]:not(:first)').each (index, el) =>
            name = el.dataset.type
            @addRegion name, "[data-type=#{name}]"
            @showChildView name, new DatapointsView
                collection:    @model[name]
                name:          name
                cardViewModel: @model


    onShow: ->
        @ui.edit.focus()


    updateInitials: (model, value) ->
        @$('.initials').text value


    syncDatapoints: ->
        @regionManager.each (region) =>
            return unless region.currentView?.getDatapoints
            name       = region.currentView.options.name
            datapoints = region.currentView.getDatapoints()
            @triggerMethod 'before:sync', name, datapoints
        @triggerMethod 'sync'
