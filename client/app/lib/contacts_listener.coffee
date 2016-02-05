Contact = require 'models/contact'


module.exports = class ContactsListener extends CozySocketListener

    models:
        'contact': Contact

    queues:
        create: []
        update: []
        delete: []

    events: [
        'contact.create'
        'contact.update'
        'contact.delete'
    ]


    # Perform remote operation on local collection by batch of contacts to
    # avoid too many operations like sorting and filtering on the collection.
    # Makes a pause between each batch to allow the browser to perform other
    # actions during that time.
    _bulk: (queue) ->
        switch queue
            when 'delete'
                action  = 'remove'
                options = {}
            else
                action  = 'add'
                options =
                    merge: true
                    trigger: false
        options.sort = false


        if @enabled
            console.log """
            Remote action occured (#{queue}, #{action}), processing start!
            """

            nbOccurences = @queues[queue].length

            # Build batches of 50 models on which to perform operations.
            # Make a break between each batch operation performing to let the
            # browser breathes between each of them.
            # This hack is dirty, we should find something better to make the
            # massive addition less painful.
            async.whilst =>
                @queues[queue].length > 0
            , (done) =>
                list = @queues[queue].splice 0, 50
                @collection[action] list, options
                setTimeout done, 100
            , ->
                console.log """
                Remote action processing done for #{nbOccurences} for operation
                (#{queue}, #{action}).
                """
        else
            @queues[queue] = []


    constructor: ->
        super
        @_bulk = _.debounce @_bulk, 1000
        @enabled = true


    enable: ->
        @enabled = true


    disable: ->
        @enabled = false


    onRemoteCreate: (model) ->
        @queues.create.push model
        @_bulk 'create'


    onRemoteUpdate: (model) ->
        @queues.update.push model
        @_bulk 'update'


    onRemoteDelete: (model) ->
        @queues.delete.push model
        @_bulk 'delete'
