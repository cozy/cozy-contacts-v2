ContactsListener = require 'lib/contacts_listener'


comparator = (a, b) ->
    sort = @comparator.sort
    [a, b] = [a, b].map (model) ->
        name = model.get('n').split(';')
        if sort is 'gn' then "#{name[0]}#{name[1]}" else "#{name[1]}#{name[0]}"

    a.localeCompare b


module.exports = class Contacts extends Backbone.Collection

    model: require 'models/contact'

    url: 'contacts'


    initialize: ->
        app = require 'application'

        @comparator      = comparator
        @comparator.sort = app.model.get 'sort'

        @listenTo app.model, 'change:sort', (appViewModel, sort)->
            @comparator.sort = sort
            @sort()

        @listenToOnce @, 'sync', -> (new ContactsListener()).watch @


    importFromVCF: (vcard) ->
        current = 0
        cards  = vcard.split /END:VCARD[\r\n]{0,2}/gi
            .filter (vcard) -> not _.isEmpty vcard
            .map (vcard) -> "#{vcard}END:VCARD"

        @trigger 'before:import:progress', cards.length

        processCards = =>
            card = cards.pop()
            if card
                parser = new VCardParser()
                parser.read card
                @create parser.contacts[0], parse: true
                @trigger 'import:progress', ++current
                setTimeout processCards
            else
                @trigger 'import', current

        setTimeout processCards, 35
