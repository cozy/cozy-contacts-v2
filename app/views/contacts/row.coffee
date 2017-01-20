PATTERN = require('const-config').search.pattern 'text'
Slugifier = require '../../lib/slugifier'


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
        @AppViewModel = require('application').model
        @listenTo @model, 'change': @render
        @listenTo @AppViewModel, 'change:selected': @refreshChecked


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
            selected: @model.id in @AppViewModel.get 'selected'
            fullname: @model.toString @_format
            isAvatarLoaded: @_isAvatarLoaded
            bg: ColorHash.getColor @model.get('n'), 'cozy'


    highlight: ->
        filter = @AppViewModel.get('filter')?.match PATTERN
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
