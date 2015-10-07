GroupViewModel = require 'views/models/group'

Search    = require 'collections/search'
CharIndex = require 'collections/charindex'


module.exports = class Contacts extends Mn.CompositeView

    template: ->

    attributes:
        role: 'list'
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
        app = require 'application'
        @taggedCollection = new Search app.contacts
        @_buildFilteredCollections()


    _buildFilteredCollections: ->
        initials    = '#abcdefghijklmnopqrstuvwxyz'
        @collection = new Backbone.Collection()

        for char in initials
            do (char) =>
                attributes = name: char
                collection = new CharIndex @taggedCollection, char: char
                @collection.add new GroupViewModel attributes,
                    compositeCollection: collection


    scroll: (down) ->
        dir  = if down then 1 else -1
        incr = @_parent.$el.scrollTop() + @_parent.$el.innerHeight() * dir
        @_parent.$el.scrollTop incr


    onShow: ->
        app = require('application')
        @listenTo app.layout,
            'key:pageup':   @scroll.bind @, false
            'key:pagedown': @scroll.bind @, true
        @focus()


    focus: ->
        @$el.focus()
