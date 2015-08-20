Filtered = BackboneProjections.Filtered
{asciize, alphabet} = require 'lib/diacritics'

GroupViewModel = require 'views/models/group'

GroupView = require 'views/contacts/group'


module.exports = class Contacts extends Mn.CompositeView

    template: ->

    childView: GroupView

    childViewOptions: (model) ->
        collection: model.compositeCollection


    initialize: ->
        initials = '#abcdefghijklmnopqrstuvwxyz'
        @collection = new Backbone.Collection()

        for letter in initials
            do (letter) =>
                attributes = name: letter
                options = compositeCollection: @_filterContactsByInitial letter
                @collection.add new GroupViewModel attributes, options


    _filterContactsByInitial: (letter) ->
        letter = letter.toLowerCase()
        new Filtered require('application').contacts,
            filter: (contact) ->
                [fn, gn, ...] = contact.get('n').split ';'
                initial = asciize(fn)[0].toLowerCase()

                if letter is '#'
                    not initial.match alphabet
                else
                    initial is letter
