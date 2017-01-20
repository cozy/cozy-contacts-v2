Tag = require 'models/tag'


module.exports = class TagsListener extends CozySocketListener

    models:
        'tag': Tag

    events: [
        'tag.create'
        'tag.update'
        'tag.delete'
    ]

    onRemoteCreate: (model) ->
        @collection.add model, merge:true

    onRemoteUpdate: (model) ->
        @collection.add model, merge: true

    onRemoteDelete: (model) ->
        @collection.remove model
