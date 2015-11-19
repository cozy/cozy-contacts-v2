PATTERN = require('config').search.pattern 'text'


module.exports = class ContactRow extends Mn.ItemView

    template: require 'views/templates/contacts/row'

    tagName: 'li'

    attributes:
        role: 'row'


    ui:
        avatar: 'img.avatar'

    modelEvents:
        'change': 'render'
        'sync':   'render'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:selected', @refreshChecked
        @listenTo app.vent, 'content:scroll', @lazyLoadAvatar


    serializeData: ->
        app        = require 'application'
        filter     = app.model.get('filter')?.match PATTERN
        formatOpts =
            pre: '<b>'
            post: '</b>'

        fullname = @model.toHighlightedString filter?[1] or null,
            pre: '<span class="search">'
            post: '</span>'
            format: formatOpts

        _.extend {}, super(),
            fullname: fullname
            selected: @model.id in app.model.get 'selected'


    onShow: ->
        @lazyLoadAvatar()


    refreshChecked: (appViewModel, selected)->
        @$('[type="checkbox"]').prop 'checked', @model.id in selected


    lazyLoadAvatar: ->
        docEl          = document.documentElement
        rect           = @el.getBoundingClientRect()
        isElInViewport = rect.top <= (window.innerHeight or docEl.clientHeight)

        @ui.avatar.attr 'src', @ui.avatar.data 'src' if isElInViewport
