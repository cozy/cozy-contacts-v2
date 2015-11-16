{Sorted} = BackboneProjections
t = require 'lib/i18n'

ContactViewModel = require 'views/models/contact'
GroupViewModel   = require 'views/models/group'

CharIndex = require 'collections/charindex'


module.exports = class Contacts extends Mn.CompositeView

    template: (data) ->
        container = if data.scored then 'ul' else 'div'
        "<#{container} role='grid' tabindex='0'/><div class='counter'/>"


    getChildView: ->
        if @options.scored
            require 'views/contacts/row'
        else
            require 'views/contacts/group'

    childViewOptions: (model) ->
        if @options.scored
            model: new ContactViewModel {}, model: model
        else
            collection: model.compositeCollection

    childViewContainer: '[role=grid]'


    ui:
        navigate: '.name'

    behaviors:
        Navigator: {}
        Dropdown:  {}

    events:
        'change [type=checkbox]': 'updateBulkSelection'


    initialize: ->
        app = require 'application'
        search = app.filtered

        if @options.scored
            @collection = new Sorted search, comparator: (model) ->
                search.scores[model.id] * -1
            @bindEntityEvents @collection, 'update': 'render'

        else
            addGroupViewModel = (char) ->
                attributes = name: char
                collection = new CharIndex search, char: char
                new GroupViewModel attributes, compositeCollection: collection

            initials    = 'abcdefghijklmnopqrstuvwxyz#'
            collection  = (addGroupViewModel char for char in initials)
            @collection = new Backbone.Collection collection

        @bindEntityEvents search, 'update reset': 'updateCounter'


    onRenderCollection: ->
        @updateCounter()


    onShow: ->
        app = require('application')
        @listenTo app.layout,
            'key:pageup':   @scroll.bind @, false
            'key:pagedown': @scroll.bind @, true


    serializeData: ->
        scored: @options.scored


    updateCounter: ->
        app  = require 'application'
        size = app.filtered.size()

        label = if size
            t('list counter', {smart_count: size})
        else if app.contacts.size()
            t('list counter no-search')
        else
            t('list counter empty')

        @$('.counter')
            .text label
            .toggleClass 'important', app.filtered.isEmpty()


    scroll: (down) ->
        dir  = if down then 1 else -1
        incr = @_parent.$el.scrollTop() + @_parent.$el.innerHeight() * dir
        @_parent.$el.scrollTop incr
        @$el.focus()


    updateBulkSelection: (event) ->
        selected = event.currentTarget.checked
        id       = event.currentTarget.value
        method   = if selected then 'contacts:select' else 'contacts:unselect'

        @triggerMethod method, id
