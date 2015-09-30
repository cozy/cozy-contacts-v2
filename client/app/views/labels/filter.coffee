module.exports = class LabelFilter extends Mn.ItemView

    template: require 'views/templates/labels/filter'

    tagName: 'li'


    serializeData: ->
        app = require 'application'
        pattern = new RegExp "tag:#{@model.get 'name'}", 'i'
        _.extend {}, super,
            selected: app.model.get('filter').match pattern
