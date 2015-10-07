Contact = require 'models/contact'
ContactViewModel = require 'views/models/contact'
CompareContacts = require 'lib/compare_contacts'
ContactHelper = require 'lib/contact_helper'


CHOICE_FIELDS =  ['fn', 'org', 'title', 'department', 'bday', 'nickname']

# Merge a list of contact.
# Merge choices stored in attributes of this.
module.exports = class MergeViewModel extends Backbone.ViewModel

    initialize: (options) ->
        if options.candidates?
            @set 'toMerge', options.candidates.slice(0)
            console.log @


    selectCandidate: (index, select)->
        if select
            unless @isCandidateSelected index
                # TODO : @set 'toMerge' transform Array into Object !?
                @attributes.toMerge.push @get('candidates')[index]
        else
            @unselectCandidate index


    unselectCandidate: (index)->
        # TODO : @set 'toMerge' transform Array into Object !?
        @attributes.toMerge = @attributes.toMerge.filter (contact) =>
            return contact isnt @get('candidates')[index]



    isCandidateSelected: (index) ->
        return @get('candidates')[index] in @get('toMerge')


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

        @set 'mergeOptions', mergeOptions
        return mergeOptions

    merge: (callback) ->

        console.log 'merge'
        # get form data about merging

        # Do merge
        # merged = new Contact()
        toMerge = @toMergeAsJson()

        merged =
            datapoints: []
            tags: []
        # Merge DataPoints and not specific fields
        toMerge.forEach (contact) ->
            CompareContacts.mergeContacts merged, contact

        # Handle specific fields
        delete merged._id
        delete merged.id
        delete merged.revision
        delete merged._rev
        delete merged._attachments

        # We rely on fn field to choose fn and n fields.
        fields = CHOICE_FIELDS
        if @has 'fn'
            @set 'n', @get 'fn'
            fields = fields.concat 'n'

        for field in fields
            if @has field
                merged[field] = toMerge[@get field][field]


        console.log merged
        # Create new

        contact = new Contact merged, parse: true
        result = new ContactViewModel { new: true }, model: contact


        # next = =>
        #     # modelView.attributes = contact.parse merged
        #     console.log "merged contact"
        #     console.log contact
        #     console.log modelView

        #     modelView.set 'edit', true

        #     app  = require 'application'
        #     CardView = require 'views/contacts/card'

        #     contactView = new CardView model: modelView
        #     app.layout.showChildView 'dialogs', contactView

        #     @model.prepareLastStep contactView, modelView

        end = (err) =>
            @set 'result', result
            @trigger 'merged', @
            @saveResult()
            callback err if callback?

        # Avatar picture
        if @has 'avatar'
            uri = "contacts/#{toMerge[@get('avatar')].id}/picture.png"

            ContactHelper.imgUrl2DataUrl uri, (err, dataUrl) =>
                result.set 'avatar', dataUrl

                end err
        else
            end()



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

    saveResult: ->
        console.log 'save result'
        result = @get 'result'
        @listenTo result, 'save', @destroyToMerge.bind @

        result.save()

    # Deprecated
    prepareLastStep: (contactView, contact) ->
        @listenTo contact, 'save', ()=>
            console.log "merge save contact, destroy toMerge"
            @destroyToMerge()

        # TODO : may be called before save ...
        # when contact view close, merge is over, destroy
        @listenTo contactView, 'destroy', ()=>
            console.log "destroy merge viewmodel"
            @trigger 'done'

            @stopListening()


