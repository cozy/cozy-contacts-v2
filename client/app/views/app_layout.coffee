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

    regions:
        content: '[role=contentinfo]'
        drawer:  'aside'
        toolbar: '[role=toolbar]'
        card:    '.container .card'

    ui:
        backdrop: '.container [role=separator]'

    keymaps:
        '33': 'key:pageup'
        '34': 'key:pagedown'

    triggers:
        'click @ui.backdrop': 'click:backdrop'


    initialize: ->
        app = require('application')

        @listenTo app.contacts, 'sync', @showContactsList
        @listenTo app.contacts, 'sync', @disableBusyState

        @on 'render', @showDrawer
        @on 'render', @showToolbar

        @listenTo @card, 'show', @toggleCardContainer.bind @, true
        @listenTo @card, 'before:empty', @toggleCardContainer.bind @, false

        @on 'click:backdrop', => @card.reset()


    disableBusyState: ->
        @$el.attr 'aria-busy', false


    showDrawer: ->
        @showChildView 'drawer', new DrawerLayout()


    showToolbar: ->
        @showChildView 'toolbar', new SearchView()


    showContactsList: ->
        @showChildView 'content', new ContactsView()


    showContact: (model) ->
        modelView = new ContactViewModel {}, model: model
        @showChildView 'card', new CardView model: modelView


    toggleCardContainer: (visible) ->
        $container = @card.$el.parent()
        visible ?= $container.attr('aria-hidden') isnt 'true'
        @card.$el.parent().attr 'aria-hidden', not visible
