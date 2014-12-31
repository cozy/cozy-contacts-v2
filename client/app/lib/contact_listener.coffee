Contact = require '../models/contact'

module.exports = class ContactListener extends CozySocketListener

    models:
        'contact': Contact

    events: [
        'contact.create'
        'contact.update'
        'contact.delete'
    ]

    onRemoteCreate: (model) ->
        @collection.add model, merge: true

    onRemoteUpdate: (model, collection) ->
        @collection.add model, merge: true

    onRemoteDelete: (model) ->
        @collection.remove model

    process: (event) ->
        super event

        # overrides to force a change event to update
        # the currently opened contact if needed
        if event.operation is 'update'
            model = @collection.get event.id
            model.trigger 'change', model
