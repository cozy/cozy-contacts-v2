CHOICE_FIELDS =  ['fn', 'org', 'title', 'department', 'bday', 'nickname','note']
module.exports = class MergeViewModel extends Backbone.ViewModel

    # defaults:
    #     toMerge: []

    toMergeAsJson: ->
        return @get('toMerge').map (contact) -> contact.toJSON()


    buildMergeOptions: ->
        mergeOptions = {}
        fields = CHOICE_FIELDS.concat 'avatar'

        toMerge = @toMergeAsJson()
        for field in fields
            options = []
            toMerge.forEach (contact, index) ->
                if field is 'avatar'
                    if contact._attachments?
                        value = "contacts/#{contact.id}/picture.png"
                    else
                        value = null
                else
                    value = contact[field]

                # Remove useless values, and filter identical value.
                if value? and value isnt '' and not (options.some (option)->
                    option.value is value)
                        options.push
                            value: value
                            index: index

            if options.length is 1 # choice is done already
                @set field, options[0].index

            # Ask for a choice if there is anything to choose.
            else if options.length > 1
                mergeOptions[field] = options

        return mergeOptions


    # merge: (callback) ->
    #     console.log 'merge'

    #     # Do merge
    #     # merged = new Contact()
    #     toMerge = @toMergeAsJson()

    #     # Initialize row data of the created merged contact.
    #     merged =
    #         datapoints: []
    #         tags: []

    #     # Merge DataPoints and not specific fields
    #     toMerge.forEach (contact) ->
    #         CompareContacts.mergeContacts merged, contact

    #     console.log @model

    #     # We rely on fn field to choose fn and n fields.
    #     fields = CHOICE_FIELDS
    #     if @has 'fn'
    #         @set 'n', @get 'fn'
    #         fields = fields.concat 'n'

    #     for field in fields
    #         if @model.has field
    #             merged[field] = toMerge[@model.get field][field]
    #             # merged[field] = @model.get field

    #     # # Avatar picture
    #     # if @model.has 'avatar'


    #     console.log merged
    #     # Create new
    #     Contact = require 'models/contact'
    #     ContactViewModel = require 'views/models/contact'

    #     contact = new Contact merged, parse: true

    #     modelView = new ContactViewModel { new: true }, model: contact

    #     next = =>
    #         # modelView.attributes = contact.parse merged
    #         console.log "merged contact"
    #         console.log contact
    #         console.log modelView

    #         modelView.set 'edit', true

    #         app  = require 'application'
    #         CardView = require 'views/contacts/card'

    #         contactView = new CardView model: modelView
    #         app.layout.showChildView 'dialogs', contactView

    #         @model.prepareLastStep contactView, modelView


    #     # Avatar picture
    #     if @model.has 'avatar'
    #         # get url :
    #         uri = "contacts/#{toMerge[@model.get('avatar')].id}/picture.png"


    #         @_imgUrl2DataUrl uri, (err, dataUrl) =>
    #             modelView.set 'avatar', dataUrl

    #             next()
    #     else
    #         next()

    destroyToMerge: ->
        # Delete olds
        toMerge = @get 'toMerge'
        console.log toMerge

        async.each toMerge, (c, cb) ->
            c.destroy
                success: (model, response, option) -> cb()
                error: (model, response, option) -> cb response
        , (err) ->
            if err
                console.log err
            else
                console.log "deleted"

    prepareLastStep: (contactView, contact) ->
        @listenTo contact, 'save', ()=>
            console.log "merge save contact, destroy toMerge"
            @destroyToMerge()

        # TODO : my called before save ...
        # when contact view close, merge is over, destroy
        @listenTo contactView, 'destroy', ()=>
            console.log "destroy merge viewmodel"
            @stopListening()


