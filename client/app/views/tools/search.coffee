module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'

    tagName: 'label'

    className: 'empty'

    attributes:
        for: 'contacts-search'


    ui:
        'search': 'input'
        'clear': 'button.clear'


    events: ->
        _updateSearch = _.debounce @updateSearch, 350
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
        @ui.search.trigger 'focus'


    toggleUi: (value) ->
        @$el.toggleClass 'empty', _.isEmpty value
