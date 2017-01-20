SearchView   = require 'views/tools/search'


module.exports = class ToolbarView extends Mn.ItemView

    template: require 'views/templates/tools/toolbar'


    ui:
        drawer: '.drawer-toggle'

    triggers:
        'click @ui.drawer': 'drawer:toggle'


    onRender: ->
        # NOTE: A probable better way is to use Backbone.BabySitter to tracks
        # children views.
        (new SearchView()).render().$el.appendTo @$el
