Contact = require 'models/contact'
ContactViewModel = require 'views/models/contact'
CompareContacts = require 'lib/compare_contacts'
ContactHelper = require 'lib/contact_helper'


CHOICE_FIELDS =  ['org', 'title', 'department', 'bday', 'nickname']

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

        # Trigger manually as we set value trough @attributes.
        @trigger 'change', @


    unselectCandidate: (index)->
        # TODO : @set 'toMerge' transform Array into Object !?
        @attributes.toMerge = @attributes.toMerge.filter (contact) =>
            return contact isnt @get('candidates')[index]


    isCandidateSelected: (index) ->
        return @get('candidates')[index] in @get('toMerge')


    toMergeAsJson: ->
        return @get('toMerge').map (contact) -> contact.toJSON()


    isMergeable: ->
        return not @has('result') and @get('toMerge').length > 1


    buildMergeOptions: ->
        mergeOptions = {}
        fields = CHOICE_FIELDS.concat ['avatar', 'fullname']

        for field in fields
            options = []
            @get('toMerge').forEach (contact, index) ->
                if field is 'avatar'
                    if contact.has '_attachments'
                        value = "contacts/#{contact.get('id')}/picture.png"
                    else
                        value = null
                else if field is 'fullname'
                    value = contact.toString pre: '<b>', post: '</b>'
                else
                    value = contact.get field

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

        # Defensive: merge shouldn't be called with nothing to do.
        if toMerge.length <= 1
            return callback new Error 'not enought contact to merge.'

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

        # We rely on fullname choice to choose fn and n fields.
        fields = CHOICE_FIELDS
        if @has 'fullname'
            @set 'n', @get 'fullname'
            @set 'fn', @get 'fullname'
            fields = fields.concat ['n', 'fn']

        for field in fields
            if @has field
                merged[field] = toMerge[@get field][field]

        # Create the new contact and ContactViewModel
        # contact = new Contact merged, parse: true
        result = new Contact merged, parse: true
        #result = new ContactViewModel { new: true }, model: contact

        end = (err) =>
            return callback err if err
            @listenToOnce result, 'sync', @afterSyncResult.bind @
            result.save()

            callback() if callback?

        # Avatar picture
        if @has 'avatar'
            uri = "contacts/#{toMerge[@get('avatar')].id}/picture.png"

            ContactHelper.imgUrl2DataUrl uri, (err, dataUrl) ->
                result.set 'avatar', dataUrl.split(',')[1]

                end err
        else
            end()


    # Delete old contacts, now merged in 'result',
    # clean toMerge and candidates fields,
    # trigger contacts:merged
    # and add the new merged result to the cmain contacts collection.
    afterSyncResult: (result)->
        async.each @get('toMerge'), (contact, cb) ->
            contact.destroy
                success: -> cb()
                error: (model, response, option) -> cb response

        , (err) =>
            if err
                console.error err
                # TODO : passing err as second arguments may be confusing ?
                @trigger 'contacts:merge', @, err
            else
                @attributes.toMerge = []
                @attributes.candidates = []
                @set 'result', result
                @trigger 'contacts:merge', @, null

            # Add the contacts after trigger, because add to main contacts
            # collection is a sensitive overhead (~1s)
            {contacts} = require('application')
            contacts.add result, sort: false
