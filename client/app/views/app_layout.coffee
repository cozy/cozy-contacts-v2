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
            behaviorClass: require 'lib/behaviors/keyboard'
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    regions:
        content: '[role=contentinfo]'
        drawer:  'aside'
        toolbar: '[role=toolbar]'
        dialogs:
            selector: '.dialogs'
            regionClass: require 'lib/regions/dialogs'

    modelEvents:
        'change:dialog': 'showContact'

    childEvents:
        'dialog:close': -> @model.set 'dialog', false


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
