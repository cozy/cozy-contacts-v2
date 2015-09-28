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
MergeView     = require 'views/contacts/merge'


DuplicatesView = require 'views/duplicates'


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

    showDialog: (viewModel, slug) ->
        if slug is 'duplicates'
            @showChildView 'dialogs', new DuplicatesView()

        else if slug is 'merge'
            @showChildView 'dialogs', new MergeView()

        else
            @showContact viewModel, slug

    showContact: (viewModel, id) ->
        if id
            app = require 'application'
            model = if id is 'new' then new ContactModel null, parse: true
            else app.contacts.get id

            modelView = new ContactViewModel {new: id is 'new'}, model: model
            app.on 'mode:edit', (edit) -> modelView.set 'edit', edit

            @showChildView 'dialogs', new CardView model: modelView
        else
            @dialogs.empty()
            @content.currentView.focus()
