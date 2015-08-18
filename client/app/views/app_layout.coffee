###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

DrawerLayout = require 'views/drawer_layout'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layout_app'

    el: '[role=application]'

    regions:
        content: '[role=contentinfo]'
        drawer : '[role=complementary]'


    initialize: ->
        @on 'render', @showDrawer


    showDrawer: ->
        @showChildView 'drawer', new DrawerLayout model: @model
