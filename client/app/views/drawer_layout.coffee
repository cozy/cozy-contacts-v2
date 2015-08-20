###
Drawer Layout

reate a layout view for the Drawer. It handles regions to render:
- selection links
- actions buttons
- labels
- sub-actions buttons

It handles a `mode` that reflects its rendering context.
###

DrawerViewModel = require 'views/models/drawer'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/drawer'

    className: 'tools'


    initialize: ->
        @model = new DrawerViewModel {}, model: require('application').model
