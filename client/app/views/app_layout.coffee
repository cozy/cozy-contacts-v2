###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

ContactModel = require 'models/contact'

ContactViewModel = require 'views/models/contact'

DefaultActionsTool = require 'views/tools/default_actions'
ContextActionsTool = require 'views/tools/context_actions'
LabelsFiltersTool  = require 'views/labels'
ToolbarView        = require 'views/tools/toolbar'
ContactsView       = require 'views/contacts'
CardView           = require 'views/contacts/card'
DuplicatesView     = require 'views/duplicates'
SettingsView       = require 'views/settings'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role=application]'

    behaviors:
        Navigator: {}
        Keyboard:
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    ui:
        navigate: 'aside [role=button]'


    regions:
        actions: 'aside .tool-actions'
        labels:  'aside .tool-labels'
        content: 'main [role=contentinfo]'
        toolbar: 'main [role=toolbar]'
        dialogs:
            selector: '.dialogs'
            regionClass: require 'lib/regions/dialogs'
        alerts:
            selector: '.alerts'
            regionClass: require 'lib/regions/dialogs'


    modelEvents:
        'change:dialog': 'showDialog'
        'change:selected': 'swapContextualMenu'

    childEvents:
        'drawer:toggle':     'toggleDrawer'
        'contacts:select':   (contactsView, id) -> @model.select id
        'contacts:unselect': (contactsView, id) -> @model.unselect id
        'dialog:close':      -> @model.set 'dialog', false


    initialize: ->
        app = require 'application'
        @listenToOnce app.contacts, 'sync', ->
            @showContactsList()
            @disableBusyState()
        @listenToOnce app.tags, 'sync', ->
            @showFilters()
        @listenTo @model, 'change:scored', (appViewModel, scored)->
            @showContactsList scored


    onRender: ->
        @showChildView 'toolbar', new ToolbarView()
        @showChildView 'actions', new DefaultActionsTool()


    disableBusyState: ->
        @$el.attr 'aria-busy', false


    showFilters: ->
        @showChildView 'labels', new LabelsFiltersTool model: @model


    showContactsList: (scored = false)->
        @showChildView 'content', new ContactsView scored: scored


    showDialog: (appViewModel, slug) ->
        unless slug
            @dialogs.empty()
            @content.currentView.$el.focus()
        else
            dialogView = switch slug
                when 'settings'   then new SettingsView model: @model
                when 'duplicates' then new DuplicatesView()
                else                   @_buildContactView slug

            @showChildView 'dialogs', dialogView


    _buildContactView: (id) ->
        app = require 'application'
        model = if id is 'new' then new ContactModel null, parse: true
        else app.contacts.get id

        modelView = new ContactViewModel {new: id is 'new'}, model: model
        app.on 'mode:edit', (edit) -> modelView.set 'edit', edit

        new CardView model: modelView


    toggleDrawer: ->
        $drawer = @$ 'aside.drawer'
        isVisible = $drawer.attr('aria-expanded') is 'true'
        $drawer.attr 'aria-expanded', not isVisible


    swapContextualMenu: (appViewModel, selected) ->
        prev = appViewModel._previousAttributes.selected
        return if prev.length and selected.length

        if _.isEmpty selected
            @showChildView 'actions', new DefaultActionsTool()
        else
            @showChildView 'actions', new ContextActionsTool model: @model
