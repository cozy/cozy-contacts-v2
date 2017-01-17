PATTERN = require('config').search.pattern 'text'
Slugifier = require '../../lib/slugifier'

app = undefined

module.exports = class ContactRow extends Backbone.View

    supportsRenderLifecycle: false

    tagName: 'li'

    attributes:
        role: 'row'


    _format:
        pre: '<b>'
        post: '</b>'

    _isAvatarLoaded: false


    initialize: ->
        app = require 'application'

        @listenTo @model, 'change': @render
        @listenTo app.model, 'change:selected': @refreshChecked


    render: ->
        el   = @el
        data = @serializeData()
        tags = @model.get 'tags'

        if tags
            el.className = tags
                # See TagsRouter#filter and
                # https://github.com/cozy/cozy-contacts/issues/262
                .map Slugifier.slugify
                .map (slug) -> "tag_#{slug}"
                .join ' '

        template     = require 'views/templates/contacts/row'
        el.innerHTML = template data

        window.requestAnimationFrame @lazyLoadAvatar

        @highlight()


    serializeData: ->
        _.extend @model.toJSON(),
            selected: @model.id in app.model.get 'selected'
            fullname: @model.toString @_format
            isAvatarLoaded: @_isAvatarLoaded


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


    lazyLoadAvatar: =>
        return if @_isAvatarLoaded

        docEl          = document.documentElement
        imgEl          = @el.querySelector 'img.avatar'
        rect           = @el.getBoundingClientRect()
        isElInViewport = rect.top <= (window.innerHeight or docEl.clientHeight)

        if isElInViewport and imgEl
            imgEl.setAttribute 'src', imgEl.dataset.src
            @_isAvatarLoaded = true
        else
            window.requestAnimationFrame @lazyLoadAvatar
