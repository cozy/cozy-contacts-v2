comparator = (a, b) ->
    a = a.get('n').split ';'
    b = b.get('n').split ';'

    index = switch @comparator.sort
        when 'gn' then 0
        when 'fn' then 1
        else           0

    a[index].localeCompare b[index]


module.exports = class Contacts extends Backbone.Collection

    model: require 'models/contact'

    url: 'contacts'


    initialize: ->
        app = require('application')

        @comparator      = comparator
        @comparator.sort = app.model.get 'sort'

        @listenTo app.model, 'change:sort', (appViewModel, sort)->
            @comparator.sort = sort
            @sort()


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
