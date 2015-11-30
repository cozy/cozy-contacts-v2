###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

ContactModel = require 'models/contact'

ContactViewModel            = require 'views/models/contact'
ContactViewModelsCollection = require 'views/collections/contacts'

DefaultActionsTool = require 'views/tools/default_actions'
ContextActionsTool = require 'views/tools/context_actions'
LabelsFiltersTool  = require 'views/labels'
ToolbarView        = require 'views/tools/toolbar'
ContactsView       = require 'views/contacts'
CardView           = require 'views/contacts/card'
DuplicatesView     = require 'views/duplicates'
SettingsView       = require 'views/settings'

t = require 'lib/i18n'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role="application"]'

    behaviors:
        Navigator: {}
        Dropdown:  {}
        Keyboard:
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    ui:
        navigate: 'aside [role="button"], .name'
        content:  'main [role="contentinfo"] '
        counter:  'main .counter'

    regions:
        actions: 'aside .tool-actions'
        labels:  'aside .tool-labels'
        content: '@ui.content [role="grid"]'
        toolbar: 'main [role="toolbar"]'
        dialogs:
            selector: '.dialogs'
            regionClass: require 'lib/regions/dialogs'
        alerts:
            selector: '.alerts'
            regionClass: require 'lib/regions/dialogs'


    modelEvents:
        'change:dialog':   'showDialog'
        'change:selected': 'swapContextualMenu'
        'change:scored':   'showContactsList'

    childEvents:
        'drawer:toggle':     'toggleDrawer'
        'contacts:select':   (contactsView, id) -> @model.select id
        'contacts:unselect': (contactsView, id) -> @model.unselect id
        'dialog:close':      -> @model.set 'dialog', false


    initialize: ->
        app = require 'application'

        @underlyingContacts = new ContactViewModelsCollection app.contacts

        @listenToOnce app.contacts, 'sync', ->
            @showContactsList()
            scroller = _.debounce (-> app.vent.trigger 'content:scroll'), 80
            @ui.content.on 'scroll', scroller

        @listenToOnce app.tags, 'sync', @showFilters

        @bindEntityEvents app.vent,
            'busy:enable':  -> @$el.attr 'aria-busy', true
            'busy:disable': -> @$el.attr 'aria-busy', false


    onRender: ->
        @showChildView 'toolbar', new ToolbarView()
        @showChildView 'actions', new DefaultActionsTool()


    onKeyPageup: ->
        el = @ui.content[0]
        el.scrollTop -= el.offsetHeight


    onKeyPagedown: ->
        el = @ui.content[0]
        el.scrollTop += el.offsetHeight


    showFilters: ->
        @showChildView 'labels', new LabelsFiltersTool model: @model


    showContactsList: ->
        app = require 'application'

        view = new ContactsView collection: @underlyingContacts

        @listenTo view,
            'dom:refresh': ->
                app.vent.trigger 'busy:disable'
                @ui.content.trigger 'focus' unless app.model.get 'scored'
                @updateCounter()
            'filter': ->
                setTimeout => @updateCounter()

        setTimeout => @showChildView 'content', view


    showDialog: (appViewModel, slug) ->
        unless slug
            @dialogs.empty()
        else
            dialogView = switch slug
                when 'settings'   then new SettingsView model: @model
                when 'duplicates' then new DuplicatesView()
                else                   @_buildContactView slug

            @showChildView 'dialogs', dialogView


    _buildContactView: (id) ->
        app = require 'application'
        if id is 'new'
            model = new ContactModel null, parse: true
        else
            model = app.contacts.get id

        viewModel = new ContactViewModel {new: id is 'new'}, model: model
        viewModel.listenTo app.vent, 'mode:edit', (edit) -> @set 'edit', edit

        new CardView model: viewModel


    updateCounter: ->
        size = require('application').getSelected().length

        label = if size
            t('list counter', {smart_count: size})
        else unless @underlyingContacts.isEmpty()
            t('list counter no-search')
        else
            t('list counter empty')

        @ui.counter
            .text label
            .toggleClass 'important', not size


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
