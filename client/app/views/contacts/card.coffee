AvatarView      = require 'views/contacts/components/avatar'
DataView        = require 'views/contacts/components/data'
TagsActionsView = require 'views/contacts/components/edit_tags'

t = require 'lib/i18n'

CONFIG = require('config').contact


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
        PickAvatar: {}
        Confirm: triggers: 'click @ui.btnDelete': @_deleteModalCfg()


    ui:
        btnEdit:    '.edit[role=button]'
        btnDelete:  'button.delete'
        # NavigatorBehavior Ui
        navigate:   '[href^=contacts], [data-next]'
        # FormBehavior Ui
        formSubmit: '[type=submit]'
        formClear:  'button.clear'
        formInputs: '.group:not([data-cid]) :input:not(button)'
        avatar:     '.avatar'

    regions:
        'avatar': '[role=img]'
        'data':   '.data'
        'tags':   'aside .tags'


    modelEvents:
        'change:edit':     'render'
        'save':            'onSave'
        'destroy':         -> @triggerMethod 'dialog:close'


    childEvents:
        'form:key:enter': 'onFormKeyEnter'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super, lists: CONFIG.datapoints.types


    _deleteModalCfg: ->
        opts = name: @options.model.get 'fn'

        return cfg =
            event:      'delete'
            title:      t 'card confirm delete title', opts
            message:    t 'card confirm delete message', opts
            btn_ok:     t 'card confirm delete ok'
            btn_cancel: t 'card confirm delete cancel'


    onRender: ->
        @showChildView 'avatar', new AvatarView model: @model
        @showChildView 'data', new DataView model: @model
        @showChildView 'tags', new TagsActionsView model: @model


    onDomRefresh: ->
        if @model.get('edit') then @ui.formInputs.first().focus()
        else @ui.btnEdit.focus()


    onSave: ->
        return unless @model.get 'new'
        app  = require 'application'
        dest = "contacts/#{@model.get 'id'}"
        app.router.navigate dest, trigger: true


    onEditCancel: ->
        @triggerMethod 'dialog:close' if @model.get 'new'


    onFormKeyEnter: ->
        inputs = @$ ':input:not(button):not([type=hidden])'
        inputs.eq(inputs.index(document.activeElement) + 1).focus()
