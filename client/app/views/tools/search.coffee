module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'

    tagName: 'form'


    ui:
        'search': 'input'

    events: ->
        'keyup @ui.search': _.debounce @updateSearch, 850


    updateSearch: (event) ->
        app = require 'application'
        app.search 'text', event.currentTarget.value
