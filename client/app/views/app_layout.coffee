###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

ContactViewModel = require 'views/models/contact'

DrawerLayout = require 'views/drawer_layout'
SearchView   = require 'views/tools/search'
ContactsView = require 'views/contacts'
CardView     = require 'views/contacts/card'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role=application]'

    behaviors:
        Keyboard:
            behaviorClass: require 'behaviors/keyboard'
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    regions:
        content: '[role=contentinfo]'
        drawer:  'aside'
        toolbar: '[role=toolbar]'
        dialogs: '.dialogs'

    modelEvents:
        'change:dialog': 'showContact'


    initialize: ->
        @listenTo @dialogs, 'show', @_showDialog
        @listenTo @dialogs, 'before:empty', @_hideDialog


    toggleDialogs: (visible) ->
        visible ?= @dialogs.$el.attr('aria-hidden') isnt 'true'
        @dialogs.$el.attr 'aria-hidden', not visible


    _showDialog: ->
        @listenTo @dialogs.currentView, 'dialog:close', =>
            @model.set 'dialog', false
        @toggleDialogs true


    _hideDialog: ->
        @stopListening @dialogs.currentView
        @toggleDialogs false


    onRender: ->
        @showChildView 'drawer', new DrawerLayout()
        @showChildView 'toolbar', new SearchView()


    disableBusyState: ->
        @$el.attr 'aria-busy', false


    showContactsList: ->
        @showChildView 'content', new ContactsView()


    showContact: (viewModel, id) ->
        if id
            app = require 'application'
            model = app.contacts.get id
            modelView = new ContactViewModel {}, model: model
            @showChildView 'dialogs', new CardView model: modelView
        else
            @dialogs.empty()
