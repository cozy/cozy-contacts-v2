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
                filterByValue = (option) -> option.value is value
                if value? and value isnt '' and not options.some(filterByValue)
                    options.push
                        value: value
                        index: index

            if options.length > 0
                # Default choice
                @set field, options[0].index

            # Ask for a choice if there multiple options.
            if options.length > 1
                mergeOptions[field] = options

        @set 'mergeOptions', mergeOptions
        return mergeOptions


    merge: (callback) ->
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

        # Create the new contact and ContactViewModel
        contact = new Contact merged, parse: true
        result = new ContactViewModel { new: true }, model: contact

        end = (err) =>
            @set 'result', result
            @saveResult()
            callback err if callback?

        # Avatar picture
        if @has 'avatar'
            uri = "contacts/#{toMerge[@get('avatar')].id}/picture.png"

            ContactHelper.imgUrl2DataUrl uri, (err, dataUrl) ->
                result.set 'avatar', dataUrl

                end err
        else
            end()



    # Delete old contacts, now merged in 'result'.
    destroyToMerge: ->
        toMerge = @get 'toMerge'

        # TODO : don't work, as no c.destroy success callback !
        # async.eachSeries toMerge, (c, cb) ->
        toMerge.forEach (c) -> c.destroy error: (model, response, option) ->
            console.log new Error response

        @trigger 'merged', @

            # c.destroy
            #     success: (model, response, option) -> cb()
            #     error: (model, response, option) -> cb response
        # , (err) =>
        #     if err
        #         console.log err
        #     else
        #         console.log "delete done !"
        #         @trigger 'merged', @

    saveResult: ->
        result = @get 'result'
        @listenToOnce result, 'save', @destroyToMerge.bind @

        result.save()
