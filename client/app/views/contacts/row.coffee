PATTERN = require('config').search.pattern 'text'


module.exports = class ContactRow extends Backbone.View

    tagName: 'li'

    attributes:
        role: 'row'


    initialize: ->
        app = require 'application'

        @listenTo @model, 'change', @render
        @listenTo app.model, 'change:selected', @refreshChecked
        @listenTo app.vent, 'content:scroll', @lazyLoadAvatar


    render: ->
        el   = @el
        data = @serializeData()

        template     = require 'views/templates/contacts/row'
        el.innerHTML = template data


    serializeData: ->
        app    = require 'application'
        filter = app.model.get('filter')?.match PATTERN
        format =
            pre: '<b>'
            post: '</b>'

        data = @model.toJSON()
        data.selected = @model.id in app.model.get 'selected'
        data.fullname = if filter
            @model.toHighlightedString filter[1],
                pre: '<span class="search">'
                post: '</span>'
                format: format
        else
            @model.toString format

        return data


    refreshChecked: (appViewModel, selected)->
        @$('[type="checkbox"]').prop 'checked', @model.id in selected


    lazyLoadAvatar: ->
        docEl          = document.documentElement
        imgEl          = @el.querySelector 'img.avatar'
        rect           = @el.getBoundingClientRect()
        isElInViewport = rect.top <= (window.innerHeight or docEl.clientHeight)

        if isElInViewport and imgEl
            imgEl.setAttribute 'src', imgEl.dataset.src
