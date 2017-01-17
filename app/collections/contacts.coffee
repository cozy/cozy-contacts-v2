ContactsListener = require 'lib/contacts_listener'
Contact = require 'models/contact'


module.exports = class Contacts extends Backbone.Collection

    model: Contact
    url: 'contacts'

    sortDisabled: false


    initialize: ->
        {model} = require 'application'

        @comparator = 'sortedName'
        @listenTo model, 'change:sort': _.ary @sort, 0

        @contactListener = new ContactsListener()
        @listenToOnce @, 'sync', -> @contactListener.watch @


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
