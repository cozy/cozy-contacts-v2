###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

ContactModel = require 'models/contact'

ContactViewModel = require 'views/models/contact'

DrawerLayout = require 'views/drawer_layout'
SearchView   = require 'views/tools/search'
ContactsView = require 'views/contacts'
CardView     = require 'views/contacts/card'
DuplicatesView = require 'views/duplicates'
SettingsView = require 'views/settings'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role=application]'

    behaviors:
        Keyboard:
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    regions:
        content: 'main [role=contentinfo]'
        drawer:  'aside'
        toolbar: 'main [role=toolbar]'
        dialogs:
            selector: '.dialogs'
            regionClass: require 'lib/regions/dialogs'
        alerts:
            selector: '.alerts'
            regionClass: require 'lib/regions/dialogs'


    modelEvents:
        'change:dialog': 'showDialog'

    childEvents:
        'dialog:close': -> @model.set 'dialog', false


    initialize: ->
        app = require 'application'
        @listenToOnce app.contacts, 'sync', ->
            @showContactsList()
            @disableBusyState()


    onRender: ->
        @showChildView 'drawer', new DrawerLayout()
        @showChildView 'toolbar', new SearchView()

    disableBusyState: ->
        @$el.attr 'aria-busy', false


    showContactsList: ->
        @showChildView 'content', new ContactsView()


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
