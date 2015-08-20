###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

DrawerLayout = require 'views/drawer_layout'
ContactsView = require 'views/contacts'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role=application]'

    regions:
        content: '[role=contentinfo]'
        drawer : 'aside'
        toolbar: '[role=toolbar]'


    initialize: ->
        app = require('application')

        @on 'render', @showDrawer
        @listenTo app.contacts, 'sync', @showContactsList
        @listenTo app.contacts, 'sync', @disableBusyState


    showDrawer: ->
        @showChildView 'drawer', new DrawerLayout()


    showContactsList: ->
        @showChildView 'content', new ContactsView()


    disableBusyState: ->
        @$el.attr 'aria-busy', false
