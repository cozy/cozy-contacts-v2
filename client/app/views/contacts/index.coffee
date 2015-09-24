{Filtered, Sorted}  = BackboneProjections
{asciize, alphabet} = require 'lib/diacritics'

GroupViewModel = require 'views/models/group'


class Tagged extends Filtered
    constructor: (underlying, options = {}) ->
        app  = require 'application'
        @tag = app.model.get 'filter'

        options.filter = (model) =>
            if @tag then _.contains model.attributes.tags, @tag
            else true
        super underlying, options

        @listenTo app.model, 'change:filter', (model, value) ->
            @tag = value
            @update()

    update: ->
        if @tag then @reset @underlying.models.filter @options.filter
        else @reset @underlying.models


class ByInitial extends Filtered
    constructor: (underlying, options) ->
        options.comparator = (a, b) ->
            a.attributes.n.localeCompare b.attributes.n
        options.comparator.induced = true

        options.filter = (model) ->
            n = asciize(model.attributes.n).toLowerCase()

            [gn, fn, ...] = n.split ';'
            initial = if gn then gn[0] else if fn then fn[0] else '#'

            if options.char is '#'
                not initial.match alphabet
            else
                options.char is initial

        super


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
        @taggedCollection = new Tagged app.contacts
        @_buildFilteredCollections()


    _buildFilteredCollections: ->
        initials    = '#abcdefghijklmnopqrstuvwxyz'
        @collection = new Backbone.Collection()

        for char in initials
            do (char) =>
                attributes = name: char
                collection = new ByInitial @taggedCollection, char: char
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
