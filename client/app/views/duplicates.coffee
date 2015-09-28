t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class DuplicatesView extends Mn.ItemView

    template: require 'views/templates/duplicates'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'


    initialize: ->
        console.log 'initialize view'
        app = require 'application'
        # Mn.bindEntityEvents @model, @, @model.viewEvents

        # Generate duplicates list.

        CompareContacts = require "lib/compare_contacts"

        @duplicates = CompareContacts.findSimilars app.contacts.toJSON()

        # @duplicates = [app.contacts.toJSON()[1..5]]
        console.log @duplicates
        # display it.

    serializeData: ->
        return duplicates: @duplicates
        # _.extend super, lists: CONFIG.datapoints.types

    behaviors: ->
    #     opts =
    #         name: @options.model.get 'fn'

    #     Navigator: {}
        Dialog:    {}
    #     Form:      {}
    #     Dropdown:  {}
    #     Confirm:
    #         triggers:
    #             'click @ui.delete':
    #                 event:      'delete'
    #                 title:      t 'card confirm delete title', opts
    #                 message:    t 'card confirm delete message', opts
    #                 btn_ok:     t 'card confirm delete ok'
    #                 btn_cancel: t 'card confirm delete cancel'

    # ui:
    #     navigate: '[href^=contacts], [data-next]'
    #     edit:     '.edit'
    #     delete:   '.delete'
    #     submit:   '[type=submit]'
    #     cancel:   '.cancel'
    #     inputs:   '.group:not([data-cid]) :input:not(button)'
    #     add:      '.add button'
    #     clear:    '.clear'


    # modelEvents:
    #     'change:edit':     'render'
    #     'change:initials': 'updateInitials'
    #     'change':          -> @render() unless @model.get 'edit'
    #     'before:save':     'syncDatapoints'
    #     'save':            'onSave'
    #     'destroy':         -> @triggerMethod 'dialog:close'

    # childEvents:
    #     'form:key:enter': 'onFormKeyEnter'







    # onRender: ->
    #     @$('.datapoints').each (index, el) =>
    #         name = el.dataset.type
    #         @addRegion name, "[data-type=#{name}]"
    #         @showChildView name, new DatapointsView
    #             collection:    @model[name]
    #             name:          name
    #             cardViewModel: @model

    #     @addRegion 'xtras-infos', '[data-type=xtras-infos]'
    #     @showChildView 'xtras-infos', new XtrasView model: @model

    #     return unless @model.get 'edit'

    #     @addRegion 'actions', '.actions'
    #     @showChildView 'actions', new EditActionsView model: @model


    # onDomRefresh: ->
    #     if @model.get('edit') then @ui.inputs.first().focus()
    #     else @ui.edit.focus()


    # onSave: ->
    #     return unless @model.get 'new'
    #     app  = require 'application'
    #     dest = "contacts/#{@model.get 'id'}"
    #     app.router.navigate dest, trigger: true


    # onEditCancel: ->
    #     @triggerMethod 'dialog:close' if @model.get 'new'


    # onFormKeyEnter: ->
    #     inputs = @$ ':input:not(button):not([type=hidden])'
    #     inputs.eq(inputs.index(document.activeElement) + 1).focus()


    # onFormFieldAdd: (type) ->
    #     return if type in CONFIG.xtras
    #     @getRegion('xtras').currentView.addEmptyField type


    # updateInitials: (model, value) ->
    #     @$('.initials').text value


    # syncDatapoints: ->
    #     @regionManager.each (region) =>
    #         return unless region.currentView?.getDatapoints
    #         name       = region.currentView.options.name
    #         datapoints = region.currentView.getDatapoints()
    #         @model.syncDatapoints name, datapoints
