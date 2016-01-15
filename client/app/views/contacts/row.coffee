PATTERN = require('config').search.pattern 'text'

app = undefined

module.exports = class ContactRow extends Backbone.View

    supportsRenderLifecycle: false

    tagName: 'li'

    attributes:
        role: 'row'


    _format:
        pre: '<b>'
        post: '</b>'


    initialize: ->
        app = require 'application'

        @listenTo @model, 'change', @render
        @listenTo app.model, 'change:selected', @refreshChecked
        @listenTo app.vent, 'content:scroll', @lazyLoadAvatar


    render: ->
        el   = @el
        data = @serializeData()

        el.className = @model.get('tags')?.map((tag) -> "tag_#{tag}").join(' ')

        template     = require 'views/templates/contacts/row'
        el.innerHTML = template data

        @highlight()


    serializeData: ->
        _.extend @model.toJSON(),
            selected: @model.id in app.model.get 'selected'
            fullname: @model.toString @_format


    highlight: ->
        filter = app.model.get('filter')?.match PATTERN
        return unless filter

        fullname = @model.toHighlightedString filter[1],
            pre: '<span class="search">'
            post: '</span>'
            format: @_format

        @el.querySelector('.name p').innerHTML = fullname


    refreshChecked: (appViewModel, selected)->
        @$('[type="checkbox"]').prop 'checked', @model.id in selected


    lazyLoadAvatar: ->
        docEl          = document.documentElement
        imgEl          = @el.querySelector 'img.avatar'
        rect           = @el.getBoundingClientRect()
        isElInViewport = rect.top <= (window.innerHeight or docEl.clientHeight)

        if isElInViewport and imgEl
            imgEl.setAttribute 'src', imgEl.dataset.src


    # methods aliases
    onShow: @::lazyLoadAvatar
