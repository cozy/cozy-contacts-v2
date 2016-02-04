ContactsListener = require 'lib/contacts_listener'
Contact = require 'models/contact'



module.exports = class Contacts extends Backbone.Collection

    model: Contact
    url: 'contacts'

    sortDisabled: false

    buildComparator: (sort) =>
        fn = (a, b) =>
            if fn.sort is 'gn'
                return a.get('n').localeCompare b.get('n')
            else
                nameA = a.getLastAndFirstNames()
                nameB = b.getLastAndFirstNames()
                return nameA.localeCompare nameB

        fn.sort = sort
        return fn


    initialize: ->
        {model} = require 'application'

        @comparator = @buildComparator model.get 'sort'

        @listenTo model, 'change:sort', (nil, sort) =>
            @comparator.sort = sort
            @sort()

        @listenTo @, 'change:n', @sort

        @contactListener = new ContactsListener()
        @listenToOnce @, 'sync', -> @contactListener.watch @

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


    # Turns a vcard text into a list of contacts. Then it saves every contacts
    # in the data system. Finally it reloads the contact list.
    importFromVCF: (vcard) ->
        current = 0
        cards  = vcard.trimRight().split /END:VCARD/gi
            .filter (vcard) -> not _.isEmpty vcard
            .map (vcard) -> "#{vcard}END:VCARD"

        @trigger 'before:import:progress', cards.length
        nbCards = cards.length


        # Process vcard creation. It disables the remote operation listener
        # to avoid handling the addition of contact created via the import.
        # Then it creates a contact for each vcard. When the job is done, it
        # reloads the contact list to avoid too doing sorting operation for
        # each addition.
        #
        # If the number of card is small (< 10), it simply runs the import
        # and lets being added to the list.
        @contactListener.disable() if nbCards > 10
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

                if nbCards > 10
                    @fetch reset: true
                    setTimeout @contactListener.enable, 1000

        setTimeout processCards, 35

