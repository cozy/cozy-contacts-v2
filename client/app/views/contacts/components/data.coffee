DatapointsView  = require 'views/contacts/components/datapoints'
XtrasView       = require 'views/contacts/components/xtras'
EditActionsView = require 'views/contacts/components/edit_actions'

CONFIG = require('config').contact


module.exports = class DataView extends Mn.LayoutView

    template: require 'views/templates/contacts/components/data'


    behaviors:
        Form: {}


    ui:
        formAdd: '.actions button'


    modelEvents:
        'change': -> @render() unless @model.get 'edit'

    # Force child events bubbling
    # NOTE: Mn doesn't give a proper way to do this?
    childEvents:
        'form:key:enter': -> @triggerMethod 'form:key:enter'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super, fullname: @model.toString pre: '<b>', post: '</b>'


    _renderDatapoints: ->
        @$('.datapoints').each (index, el) =>
            name = el.dataset.type
            @addRegion name, "[data-type='#{name}']"
            @showChildView name, new DatapointsView
                collection:    @model.getDatapoints(name)
                name:          name
                cardViewModel: @model

        @addRegion 'xtras-infos', '[data-type="xtras-infos"]'
        @showChildView 'xtras-infos', new XtrasView model: @model


    _renderEditActions: ->
        @addRegion 'actions', '.actions'
        @showChildView 'actions', new EditActionsView model: @model


    onRender: ->
        @_renderDatapoints()
        @_renderEditActions() if @model.get 'edit'


    onDomRefresh: ->
        return unless @model.get('edit')
        @$('input:not([type="hidden"])').eq(1).trigger 'focus'


    onFormFieldAdd: (type) ->
        xtrasView = @getRegion('xtras').currentView
        xtrasView.addEmptyField type unless type in CONFIG.xtras
