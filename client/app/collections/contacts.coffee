ContactsListener = require 'lib/contacts_listener'
Contact = require 'models/contact'



module.exports = class Contacts extends Backbone.Collection

    model: Contact
    url: 'contacts'

    sortDisabled: false

    buildComparator: (sort) =>
        fn = (a, b) =>
            if @sortDisabled
                return -1
            else
                [a, b] = [a, b].map (model) ->
                    name = model.get('n').split(';')
                    if fn.sort is 'gn'
                        "#{name[0]}#{name[1]}"
                    else
                        "#{name[1]}#{name[0]}"

                a.localeCompare b

        fn.sort = sort
        return fn


    disableSort: ->
        sortDisabled = true


    enableSort: ->
        sortDisabled = false


    initialize: ->
        {model} = require 'application'

        @comparator = @buildComparator model.get 'sort'

        @listenTo model, 'change:sort', (nil, sort) =>
            @comparator.sort = sort
            @sort()

        @listenTo @, 'change:n', @sort

        @listenToOnce @, 'sync', -> (new ContactsListener()).watch @

        # Init a map of all available tags in the contact list.
        @tagMap = {}

        # Reset or update the tag map when changes occur.
        @on 'reset', @resetTagMap
        @on 'add', @addTags
        @on 'update', @addTags


    # Rebuild available tag map by adding a key for every tag set on contacts.
    resetTagMap: ->
        @tagMap = {}
        for contact in @models
            tags = contact.get('tags') or []
            @tagMap[tag] = true for tag in tags


    # When a contact is updated or added, its tags are added to the tag map.
    # To avoid too many operations, we don't reset the whole map. The
    # counterpart is that there is no update when a tag is no more used.
    addTags: (contact) ->
        tags = contact.get('tags') or []
        @tagMap[tag] = true for tag in tags


    importFromVCF: (vcard) ->
        current = 0
        cards  = vcard.trimRight().split /END:VCARD/gi
            .filter (vcard) -> not _.isEmpty vcard
            .map (vcard) -> "#{vcard}END:VCARD"

        @trigger 'before:import:progress', cards.length


        processCards = =>
            card = cards.pop()
            if card
                parser = new VCardParser()
                parser.read card
                contactCard = parser.contacts[0]
                contact = new Contact contactCard, parse: true
                contact.save null,
                    success: =>
                        @trigger 'import:progress', ++current
                        processCards()
                    error: ->
                        processCards()
            else
                @trigger 'import', current

        setTimeout processCards, 35

