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
        'before:save': 'syncDatapoints'
        'change': -> @render() unless @model.get 'edit'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super, fullname: @model.toString pre: '<b>', post: '</b>'


    _renderDatapoints: ->
        @$('.datapoints').each (index, el) =>
            name = el.dataset.type
            @addRegion name, "[data-type=#{name}]"
            @showChildView name, new DatapointsView
                collection:    @model[name]
                name:          name
                cardViewModel: @model

        @addRegion 'xtras-infos', '[data-type=xtras-infos]'
        @showChildView 'xtras-infos', new XtrasView model: @model


    _renderEditActions: ->
        @addRegion 'actions', '.actions'
        @showChildView 'actions', new EditActionsView model: @model


    onRender: ->
        @_renderDatapoints()
        @_renderEditActions() if @model.get 'edit'


    onFormFieldAdd: (type) ->
<<<<<<< HEAD
        return if type in CONFIG.xtras
        @getRegion('xtras').currentView.addEmptyField type


    syncDatapoints: ->
        @regionManager.each (region) =>
            return unless region.currentView?.getDatapoints
            name       = region.currentView.options.name
            datapoints = region.currentView.getDatapoints()
            @model.syncDatapoints name, datapoints
=======
        xtrasView = @getRegion('xtras').currentView
        xtrasView.addEmptyField type unless type in CONFIG.xtras
>>>>>>> 333689a... Fixup datapoints revamp
