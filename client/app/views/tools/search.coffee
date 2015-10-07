module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'

    tagName: 'form'


    ui:
        'search': 'input'
        'clear': 'button.clear'

    events: ->
        updateSearch = _.debounce @updateSearch, 450
        'keyup @ui.search': (event) ->
            value = event.currentTarget.value
            @toggleUi value
            updateSearch value
        'click @ui.clear': @clearSearch


    updateSearch: (value) ->
        app = require 'application'
        app.search 'text', value


    clearSearch: (event) ->
        @ui.search.val ''
        @toggleUi ''
        @updateSearch null


    toggleUi: (value) ->
        @$('label').toggleClass 'empty', not value.length
