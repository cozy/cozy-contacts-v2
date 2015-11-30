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


    _bulk: (queue) ->
        switch queue
            when 'delete'
                action  = 'remove'
                options = {}
            else
                action  = 'add'
                options = merge: true
                
        @collection[action] @queues[queue], options
        @queues[queue].length = 0


    constructor: ->
        @_bulk = _.debounce @_bulk, 350
        super


    onRemoteCreate: (model) ->
        @queues.create.push model
        @_bulk 'create'


    onRemoteUpdate: (model) ->
        @queues.update.push model
        @_bulk 'update'


    onRemoteDelete: (model) ->
        @queues.delete.push model
        @_bulk 'delete'
