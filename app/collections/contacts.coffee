ContactsListener = require 'lib/contacts_listener'
Contact = require 'models/contact'


module.exports = class Contacts extends Backbone.Collection

    model: Contact

    sortDisabled: false


    initialize: ->
        {model} = require 'application'

        @comparator = 'sortedName'
        @listenTo model, 'change:sort': _.ary @sort, 0

        @contactListener = new ContactsListener()
        @listenToOnce @, 'sync', -> @contactListener.watch @


    fetch: (options={}, success = -> ) ->
        # This event is listened by layout
        # to display applications views
        @trigger 'sync', options

        @reset() if options.reset

        # FIXME: remove this fakeData
        # when request will work
        n = 'last name;first name;middle name;préfix;suffixe'
        datapoints = []
        datapoints.push {
            id: "06",
            name: "email",
            value: "noelie@cozycloud.cc",
            type: "work"
        }
        datapoints.push {
            id: "05",
            name: "email",
            value: "noelieandrieu@gmail.com",
            type: "work"
        }
        datapoints.push {
            id: "04",
            name: "tel",
            value: "0619384462",
            type: "main"
        }
        datapoints.push {
            id: "03",
            name: "tel",
            value: "0619384462",
            type: "portable"
        }
        datapoints.push {
            id: "02",
            name: "tel",
            value: "n0619384462",
            type: "work"
        }


        result = []
        result.push { _id: '01', n, datapoints }
        result.push { _id: '02', n, datapoints }
        result.push { _id: '03', n, datapoints }
        result.push { _id: '04', n, datapoints }
        result.push { _id: '05', n, datapoints }
        #
        @add result
        success result, @

        # cozy.init { isV2: true }
        # cozy.defineIndex 'io.cozy.contacts', ['id']
        #     .then (index) =>
        #         cozy.query index, { selector: id: {"$gte": " "} }
        #             .then (result=[]) =>
        #                 @add result
        #                 success result, @
        #             , (err) =>
        #                 success null, err



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
