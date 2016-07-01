AvatarView      = require 'views/contacts/components/avatar'
DataView        = require 'views/contacts/components/data'
TagsActionsView = require 'views/contacts/components/edit_tags'

t = require 'lib/i18n'

CONFIG = require('config').contact

app = undefined


module.exports = class ContactCardView extends Mn.LayoutView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'


    attributes:
        role: 'dialog'


    behaviors: ->
        Navigator: {}
        Dialog:    {}
        Form:      {}
        Dropdown:  {}
        Confirm: triggers: 'click @ui.btnDelete': @_deleteModalCfg


    ui:
        btnEdit:    '.edit[role="button"]'
        btnDelete:  'button.delete'
        btnExport:  '[formaction="contact/export"]'
        # NavigatorBehavior Ui
        navigate:   '[href^=contacts], [data-next]'
        # FormBehavior Ui
        formSubmit: '[type="submit"]'
        formClear:  'button.clear'
        formInputs: '.group:not([data-cid]) input,
                     .group:not([data-cid]) textarea'
        avatar:     '.avatar'

    regions:
        avatar: '[role="img"]'
        infos:  '.data'
        tags:   'aside .tags'


    triggers:
        'click @ui.btnExport': 'export'

    events:
        'click @ui.formSubmit': 'showSaving'

    modelEvents:
        'change:edit':     'render'
        'save':            'onSave'
        'destroy':         -> @triggerMethod 'dialog:close'

    childEvents:
        'form:key:enter': 'onFormKeyEnter'


    initialize: ->
        app  = require 'application'
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super, lists: CONFIG.datapoints.types


    _deleteModalCfg: =>
        opts = name: @model.get 'fn'

        return cfg =
            event:      'delete'
            title:      t 'card confirm delete title', opts
            message:    t 'card confirm delete message', opts
            btn_ok:     t 'card confirm delete ok'
            btn_cancel: t 'card confirm delete cancel'


    onRender: ->
        @showChildView 'avatar', new AvatarView model: @model
        @showChildView 'infos', new DataView model: @model
        @showChildView 'tags', new TagsActionsView
            model: @model
            collection: app.tags

        @$('[role="contentinfo"]').toggleClass 'edit', !!@model.get 'edit'


    onDomRefresh: ->
        return if @model.get 'edit'
        @ui.btnEdit.trigger 'focus'


    onSave: ->
        return unless @model.get 'new'

        dest = "contacts/#{@model.get 'id'}"
        @hideSaving()
        app.router.navigate dest, trigger: true


    onEditCancel: ->
        @triggerMethod 'dialog:close' if @model.get 'new'


    onFormKeyEnter: ->
        inputs = @$('.data.edit').find('input:not([type="hidden"]), textarea')
        if document.activeElement.tagName.toLowerCase() isnt 'textarea'
            inputs.eq(inputs.index(document.activeElement) + 1).trigger 'focus'


    # Display saving by changing aria state of save button to true (save button
    # is called form submit).
    showSaving: ->
        @ui.formSubmit.attr 'aria-busy', true


    # Display saving by changing aria state of save button to false (save
    # button is called form submit).
    hideSaving: ->
        @ui.formSubmit.attr 'aria-busy', false
