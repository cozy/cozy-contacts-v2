module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'


    ui:
        'search': 'input'
        'clear': 'button.clear'

    events: ->
        _updateSearch = _.debounce @updateSearch, 450
        'keyup @ui.search': (event) ->
            value = event.currentTarget.value
            @toggleUi value
            _updateSearch value
        'click @ui.clear': @clearSearch


    updateSearch: (value) =>
        if _.isEmpty value
            value = null
            @toggleUi()
        app = require 'application'
        app.search 'text', value


    clearSearch: ->
        @ui.search.val ''
        @toggleUi()
        @updateSearch()


    onDomRefresh: ->
        @ui.search.focus()


    toggleUi: (value) ->
        @$('label').toggleClass 'empty', _.isEmpty value
