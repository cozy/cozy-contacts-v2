{ERR} = require 'config'

app = null


module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'

    tagName: 'label'

    className: 'empty'

    attributes:
        for: 'contacts-search'


    ui:
        'search': 'input'
        'clear': 'button.clear'

    # Stores the last input value to determine if the search is done forward or
    # backward by comparing string's lengths.
    _lastValue: undefined


    events: ->
        # Clear search (test == null) when clicking on reset btn
        'click @ui.clear': -> app.search 'text', null
        # Debounce inputs in search field
        'keyup @ui.search': _.debounce (event) ->
            # handle the ESC key to clear search
            if event.which is 27
                return app.search 'text', null

            # handle the input value to get the behavior:
            # - no value: clear search
            # - input string length w/ at least 3 chars: update search
            # - less than 3 chars and backward search: trigger an error
            value = event.currentTarget.value
            if value.length is 0
                app.search 'text', null
            else if value.length > 2
                app.search 'text', value
                @_lastValue = value
            else if value.length < @_lastValue?.length
                app.channel.trigger 'search:error', ERR.SEARCH_TOO_SHORT
        # debounce at trailing end on max 350 for smooth filtering
        , 450, trailing: true, maxWait: 350


    initialize: ->
        app = require 'application'

        @listenTo app.channel,
            'filter:text': @updateSearch
            'search:error': ->
                @el.querySelector('input').setAttribute 'aria-invalid', true


    onDomRefresh: ->
        @ui.search.trigger 'focus'


    updateSearch: (value) ->
        @ui.search.val value
        @toggleUi value


    toggleUi: (value) ->
        @el.classList.toggle 'empty', _.isEmpty value
        @el.querySelector('input').setAttribute 'aria-invalid', false
