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
LabelsFiltersTool  = require 'views/labels/filters_tool'


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/drawer'

    className: 'tools'

    regions:
        actions: '.tool-actions'
        labels:  '.tool-labels'


    initialize: ->
        @model = new DrawerViewModel {}, model: require('application').model
        @on 'render', @showTools
        @listenTo require('application').tags, 'sync', @showFilters


    showTools: ->
        @showChildView 'actions', new DefaultActionsTool()


    showFilters: ->
        @showChildView 'labels', new LabelsFiltersTool
            model: @model
            collection: require('application').tags
