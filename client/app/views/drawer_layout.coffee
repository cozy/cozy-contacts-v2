###
Drawer Layout

reate a layout view for the Drawer. It handles regions to render:
- selection links
- actions buttons
- labels
- sub-actions buttons

It handles a `mode` that reflects its rendering context.
###

module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layout_drawer'

    className: 'tools'
