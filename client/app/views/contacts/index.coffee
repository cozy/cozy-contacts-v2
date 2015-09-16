{Filtered, Sorted}  = BackboneProjections
{asciize, alphabet} = require 'lib/diacritics'

GroupViewModel = require 'views/models/group'


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
        Navigator: behaviorClass: require 'lib/behaviors/navigator'
        Dropdown:  behaviorClass: require 'lib/behaviors/dropdown'


    initialize: ->
        @on 'show', @attachScrollEvents
        @_buildFilteredCollections()


    _filterContactsByInitial: (letter) ->
        letter   = letter.toLowerCase()
        contacts = new Filtered require('application').contacts,
            filter: (contact) ->
                [gn, fn, ...] = contact.get('n').split ';'
                initial = if gn then asciize(gn)[0].toLowerCase()
                else if fn then asciize(fn)[0].toLowerCase()
                else '#'

                if letter is '#'
                    not initial.match alphabet
                else
                    initial is letter
            comparator: (a, b) ->
                a.get('n').localeCompare b.get('n')


    _buildFilteredCollections: ->
        initials = '#abcdefghijklmnopqrstuvwxyz'
        @collection = new Backbone.Collection()
        for letter in initials
            do (letter) =>
                attributes = name: letter
                options = compositeCollection: @_filterContactsByInitial letter
                @collection.add new GroupViewModel attributes, options


    scroll: (down) ->
        dir  = if down then 1 else -1
        incr = @_parent.$el.scrollTop() + @_parent.$el.innerHeight() * dir
        @_parent.$el.scrollTop incr


    attachScrollEvents: ->
        app = require('application')
        @listenTo app.layout, 'key:pageup', @scroll.bind @, false
        @listenTo app.layout, 'key:pagedown', @scroll.bind @, true
        @focus()


    focus: ->
        @$el.focus()
