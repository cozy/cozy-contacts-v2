DatapointsView  = require 'views/contacts/components/datapoints'
XtrasView       = require 'views/contacts/components/xtras'
EditActionsView = require 'views/contacts/components/edit_actions'

CONFIG = require('config').contact


module.exports = class ContactCardView extends Mn.LayoutView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'


    behaviors:
        Navigator: {}
        Dialog: {}
        Form: {}
        Dropdown: {}

    ui:
        navigate: '[href^=contacts], [data-next]'
        edit:     '.edit'
        delete:   '.delete'
        submit:   '[type=submit]'
        cancel:   '.cancel'
        inputs:   '.group:not([data-cid]) :input:not(button)'
        add:      '.add button'
        clear:    '.clear'

    triggers:
        'click @ui.cancel': 'edit:cancel'
        'click @ui.delete': 'delete'


    modelEvents:
        'change:edit':     'render'
        'change:initials': 'updateInitials'
        'change':          -> @render() unless @model.get 'edit'
        'before:save':     'syncDatapoints'
        'destroy':         -> @triggerMethod 'dialog:close'

    childEvents:
        'form:enter': 'jumpToNextField'


    initialize: ->
        @model.attachViewEvents @
        @listenTo @, 'form:enter', @jumpToNextField


    serializeData: ->
        _.extend super, lists: CONFIG.datapoints.types


    onRender: ->
        @$('.datapoints').each (index, el) =>
            name = el.dataset.type
            @addRegion name, "[data-type=#{name}]"
            @showChildView name, new DatapointsView
                collection:    @model[name]
                name:          name
                cardViewModel: @model

        @addRegion 'xtras-infos', '[data-type=xtras-infos]'
        @showChildView 'xtras-infos', new XtrasView model: @model

        if @model.get 'edit'
            @addRegion 'actions', '.actions'
            @showChildView 'actions', new EditActionsView model: @model

            @listenTo @, 'form:addfield', (type) ->
                return if type in CONFIG.xtras
                @getRegion('xtras').currentView.addEmptyField type


    onDomRefresh: ->
        if @model.get('edit') then @ui.inputs.first().focus()
        else @ui.edit.focus()


    updateInitials: (model, value) ->
        @$('.initials').text value


    syncDatapoints: ->
        @regionManager.each (region) =>
            return unless region.currentView?.getDatapoints
            name       = region.currentView.options.name
            datapoints = region.currentView.getDatapoints()
            @model.syncDatapoints name, datapoints


    jumpToNextField: ->
        inputs = @$ ':input:not(button):not([type=hidden])'
        inputs.eq(inputs.index(document.activeElement) + 1).focus()
