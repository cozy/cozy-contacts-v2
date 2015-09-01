Filtered = BackboneProjections.Filtered
{asciize, alphabet} = require 'lib/diacritics'

GroupViewModel = require 'views/models/group'


module.exports = class Contacts extends Mn.CompositeView

    template: ->

    attributes:
        role: 'list'

    childView: require 'views/contacts/group'

    childViewOptions: (model) ->
        collection: model.compositeCollection

    ui:
        navigate: '.name'

    behaviors:
        Navigator:
            behaviorClass: require 'behaviors/navigator'


    initialize: ->
        @on 'show', @attachScrollEvents
        @_buildFilteredCollections()


    _filterContactsByInitial: (letter) ->
        letter = letter.toLowerCase()
        new Filtered require('application').contacts,
            filter: (contact) ->
                [gn, fn, ...] = contact.get('n').split ';'
                initial = if fn then asciize(fn)[0].toLowerCase()
                else if gn then asciize(gn)[0].toLowerCase()
                else '#'

                if letter is '#'
                    not initial.match alphabet
                else
                    initial is letter


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
