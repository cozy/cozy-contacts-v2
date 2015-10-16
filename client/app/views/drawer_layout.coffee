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

DefaultActionsTool = require 'views/tools/default_actions'
LabelsFiltersTool  = require 'views/labels/filters'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/drawer'

    className: 'tools'

    behaviors:
        Navigator: {}


    regions:
        actions: '.tool-actions'
        labels:  '.tool-labels'

    ui:
        navigate: '[role=button]'


    initialize: ->
        app    = require 'application'
        @model = new DrawerViewModel {}, model: app.model
        @listenToOnce app.tags, 'sync', @showFilters


    onRender: ->
        @showChildView 'actions', new DefaultActionsTool()


    showFilters: ->
        @showChildView 'labels', new LabelsFiltersTool
            model: @model
