module.exports = class LabelFilter extends Mn.ItemView

    template: require 'views/templates/labels/filter'

    tagName: 'li'


    serializeData: ->
        app = require 'application'
        _.extend {}, super,
            selected: app.model.get('filter') is @model.get 'name'
