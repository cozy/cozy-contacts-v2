GroupViewModel = require 'views/models/group'

Search    = require 'collections/search'
CharIndex = require 'collections/charindex'

t = require 'lib/i18n'


module.exports = class Contacts extends Mn.CompositeView

    template: ->

    attributes:
        role: 'grid'
        tabindex: 0


    childView: require 'views/contacts/group'

    childViewOptions: (model) ->
        collection: model.compositeCollection


    ui:
        navigate: '.name'

    behaviors:
        Navigator: {}
        Dropdown:  {}


    initialize: ->
        app     = require 'application'
        @search = new Search app.contacts
        @search.on 'reset update', @updateCounterLabel
        @_buildFilteredCollections()


    _buildFilteredCollections: ->
        initials    = '#abcdefghijklmnopqrstuvwxyz'
        @collection = new Backbone.Collection()

        for char in initials
            do (char) =>
                attributes = name: char
                collection = new CharIndex @search, char: char
                @collection.add new GroupViewModel attributes,
                    compositeCollection: collection


    _counterLabel: ->
        if @search.length
            t('list counter', {smart_count: @search.length})
        else if @search.search
            t('list counter no-search')
        else
            t('list counter empty')


    updateCounterLabel: =>
        @$('.counter')
            .text @_counterLabel()
            .toggleClass 'important', @search.isEmpty()

    onRenderCollection: ->
        $('<div/>', class: 'counter').appendTo @$el
        @updateCounterLabel()


    onShow: ->
        app = require('application')
        @listenTo app.layout,
            'key:pageup':   @scroll.bind @, false
            'key:pagedown': @scroll.bind @, true


    scroll: (down) ->
        dir  = if down then 1 else -1
        incr = @_parent.$el.scrollTop() + @_parent.$el.innerHeight() * dir
        @_parent.$el.scrollTop incr
        @$el.focus()
