module.exports = class LabelFilter extends Mn.ItemView

    template: require 'views/templates/labels/filter'

    tagName: 'li'


    serializeData: ->
        app      = require 'application'
        pattern  = new RegExp "tag:#{@model.get 'name'}", 'i'
        filter   = (app.model.get('filter') or '').match pattern

        _.extend {}, super, selected: !!filter
