request = require 'lib/request'
DataPoint = require 'models/datapoint'
DataPointCollection  = require 'collections/datapoint'
VCard = require 'lib/vcard_helper'

ANDROID_RELATION_TYPES = ['custom', 'assistant', 'brother', 'child',
            'domestic partner', 'father', 'friend', 'manager', 'mother',
            'parent', 'partner', 'referred by', 'relative', 'sister', 'spouse']

# A contact
# Properties :
# - dataPoints : a PhotoCollection of the photo in this album
# maintains attribute
module.exports = class Contact extends Backbone.Model

    urlRoot: 'contacts'

    constructor: ->
        @dataPoints = new DataPointCollection()
        super

    initialize: ->
        @on 'change:datapoints', =>
            dps = @get 'datapoints'
            if dps
                @dataPoints.reset dps
                @set 'datapoints', null

    defaults: ->
        n: []
        fn: ''
        note: ''
        tags: []

    # Analyze given attribute list and transform them in datapoints, Datapoint
    # is structure that describes an object (fields: name, type, value) as an
    # attribute.  For each attribute, you can have several values of different
    # type.  That's why this structure is required.
    parse: (attrs) ->
        if _.where(attrs?.datapoints, name: 'tel').length is 0
            attrs?.datapoints?.push
                name: 'tel'
                type: 'main'
                value: ''

        if _.where(attrs?.datapoints, name: 'email').length is 0
            attrs?.datapoints?.push
                name: 'email'
                type: 'main'
                value: ''

        if attrs.datapoints
            @dataPoints.reset attrs.datapoints
            delete attrs.datapoints

        if attrs._attachments?.picture
            @hasPicture = true
            delete attrs._attachments

        # On VCF parsing, base64 encoded photo is putted in attrs.photo
        if attrs.photo
            @hasPicture = true
            @photo = attrs.photo
            delete attrs.photo

        if typeof attrs.n is 'string'
            attrs.n = attrs.n.split ';'

        unless Array.isArray attrs.n
            attrs.n = @getComputedN attrs.fn

        return attrs

    savePicture: (callback) ->
        callback = callback or ->

        unless @photo
            return callback()

        else unless @get('id')?
            @save {},
                success: =>
                    @savePicture callback
        else
            #transform into a blob
            binary = atob @photo
            array = []
            for i in [0..binary.length]
                array.push binary.charCodeAt i

            blob = new Blob [new Uint8Array(array)], type: 'image/jpeg'

            data = new FormData()
            data.append 'picture', blob
            data.append 'contact', JSON.stringify @toJSON()

            markChanged = (err, body) =>
                if err
                    console.log err
                else
                    @hasPicture = true
                    @trigger 'change', this, {}
                    delete @photo

            path = "contacts/#{@get 'id'}/picture"
            request.put path, data, markChanged, false
            callback()

    getBest: (name) ->
        result = null
        @dataPoints.each (dp) ->
            if dp.get('name') is name
                if dp.get('pref') then result = dp.get 'value'
                else result ?= dp.get 'value'

        return result

    addDP: (name, type, value)=>
        @dataPoints.add
            type: type
            name: name
            value: value

    match: (filter) =>
        filter.test(@get('n')) or
        filter.test(@get('fn')) or
        filter.test(@get('note')) or
        filter.test(@get('tags').join ' ') or
        @dataPoints.match filter

    toJSON: () ->
        json = super
        json.datapoints = @dataPoints.toJSON()
        json.n = json.n.join(';') if Array.isArray json.n
        delete json.n unless json.n
        delete json.photo
        return json

    setFN: (value) ->
        @set 'fn', value
        @set 'n', @getComputedN value

    setN: (value) ->
        @set 'n', value
        @set 'fn', @getComputedFN value

    getDisplayName: ->
        n = @get 'n'
        return '' unless n and n.length > 0

        [familly, given, middle, prefix, suffix] = n
        switch app.config.get 'nameOrder'
            when 'given-familly' then "#{given} #{middle} #{familly}"

            when 'given-middleinitial-familly'
                "#{given} #{initial(middle)} #{familly}"
            else "#{familly} #{given} #{middle}"

    initial =  (middle) ->
        if i = middle.split(/[ \,]/)[0][0]?.toUpperCase() then i + '.'
        else ''

    getComputedFN: (n) ->
        n ?= @get 'n'
        return '' unless n and n.length > 0

        return VCardParser.nToFN n

    getComputedN: (fn) ->
        fn ?= @get 'fn'

        return VCardParser.fnToN fn


    # Ask to server to create a new task that says to call back current
    # contact.
    createTask: (callback) ->
        request.post "contacts/#{@id}/new-call-task", {}, callback

Contact.fromVCF = (vcf) ->
    ContactCollection = require 'collections/contact'
    parser = new VCardParser()
    parser.read vcf

    imported = new ContactCollection parser.contacts, parse: true
    return imported
