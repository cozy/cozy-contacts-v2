request = require 'lib/request'
DataPoint = require 'models/datapoint'
DataPointCollection  = require 'collections/datapoint'
ContactLogCollection = require 'collections/contactlog'
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

        @history = new ContactLogCollection
        @history.url = @url() + '/logs'
        @on 'change:id', =>
            @history.url = @url() + '/logs'

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

        if typeof attrs.n is 'string'
            attrs.n = attrs.n.split ';'

        unless Array.isArray attrs.n
            attrs.n = []

        return attrs

    getBest: (name) ->
        result = null
        @dataPoints.each (dp) ->
            if dp.get('name') is name
                if dp.get('pref') then result = dp.get 'value'
                else result ?= dp.get 'value'

        attrs?.addDP 'mail', 'main', ''

        if attrs.datapoints
            @dataPoints.reset attrs.datapoints
            delete attrs.datapoints

        if attrs._attachments?.picture
            @hasPicture = true
            delete attrs._attachments

        if typeof attrs.n is 'string'
            attrs.n = attrs.n.split ';'

        unless Array.isArray attrs.n
            attrs.n = undefined

        return attrs

    savePicture: (callback) ->
        unless @get('id')?
            @save {},
                success: =>
                    @savePicture()
        else
            data = new FormData()
            data.append 'picture', @picture
            data.append 'contact', JSON.stringify @toJSON()

            markChanged = (err, body) =>
                if err
                    console.log err
                else
                    @hasPicture = true
                    @trigger 'change', this, {}
                    delete @picture

            path = "contacts/#{@get 'id'}/picture"
            request.put path, data, markChanged, false

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
        delete json.picture
        return json

    setFN: (value) ->
        @set 'fn', value
        @set 'n', @getComputedN value

    setN: (value) ->
        @set 'n', value
        @set 'fn', @getComputedFN value

    # TODO: should be useless as fn should always exists.
    getFN: -> @get('fn') or @getComputedFN()

    # TODO: should be useless as n should always exists.
    getN: -> @get('n') or @getComputedN()

    initial =  (middle) ->
        if i = middle.split(/[ \,]/)[0][0]?.toUpperCase() then i + '.'
        else ''

    getComputedFN: (n) ->
        n ?= @get 'n'
        return '' unless n and n.length > 0

        return VCard.nToFN n

    getComputedN: (fn) ->
        fn ?= @get 'fn'

        return VCard.fnToN fn


    # Ask to server to create a new task that says to call back current
    # contact.
    createTask: (callback) ->
        request.post "contacts/#{@id}/new-call-task", {}, callback


AndroidToDP = (contact, raw) ->
    parts = raw.split ';'
    switch parts[0].replace 'vnd.android.cursor.item/', ''
        when 'contact_event'
            value = parts[1]
            type = if parts[2] in ['0', '2'] then parts[3]
            else if parts[2] is '1' then 'anniversary'
            else 'birthday'
            contact.addDP 'about', type, value
        when 'relation'
            value = parts[1]
            type = ANDROID_RELATION_TYPES[+parts[2]]
            type = parts[3] if type is 'custom'
            contact.addDP 'other', type, value

Contact.fromVCF = (vcf) ->

    # inspired by https://github.com/mattt/vcard.js

    regexps =
        begin:       /^BEGIN:VCARD$/i
        end:         /^END:VCARD$/i
        # vCard 2.1 files can use quoted-pirntable text.
        simple:      /^(version|fn|n|title|org|note)(;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE)?\:(.+)$/i
        android:     /^x-android-custom\:(.+)$/i
        composedkey: /^item(\d{1,2})\.([^\:]+):(.+)$/
        complex:     /^([^\:\;]+);([^\:]+)\:(.+)$/
        property:    /^(.+)=(.+)$/

    ContactCollection   = require 'collections/contact'
    imported = new ContactCollection()
    currentversion = "3.0"

    current = null
    currentidx = null
    currentdp = null

    # unfold folded fields (like photo)
    # some vCard 2.1  files use = at end of line
    # instead of space a start of next line.
    unfolded = vcf.replace /(\r?\n\s)|(=\r?\n)/gm, ''
    for line in unfolded.split /\r?\n/

        if regexps.begin.test line
            current = new Contact()

        else if regexps.end.test line
            current.dataPoints.add currentdp if currentdp
            imported.add current

            # There is two fields N and FN that does the same thing but not the
            # same way. Some vCard have one or ther other, or both.
            # If both are present, we keep them.
            # If only one is present, we compute the other one.
            if not current.has('n') and not current.has('fn')
                console.error 'There should be at least a N field or a FN field'

            if not current.has('n') or _.compact(current.get 'n').length is 0
                current.set 'n', current.getComputedN()

            if not current.has 'fn'
                    current.set 'fn', current.getComputedFN()

            currentdp = null
            current = null
            currentidx = null
            currentversion = "3.0"

        else if regexps.simple.test line
            [all, key, quoted..., value] = line.match regexps.simple
            if quoted.length is 1
                value = VCard.unquotePrintable value

            key = key.toLowerCase()

            switch key
                when 'version' then currentversion = value
                when 'title', 'org'
                    current.addDP 'about', key, value
                when 'fn', 'note'
                    current.set key, value
                when 'n'
                    current.set key, value.split ';'
                when 'bday'
                    current.addDP 'about', 'birthday', value

        else if regexps.android.test line
            [all, value] = line.match regexps.android
            AndroidToDP current, value

        else if regexps.composedkey.test line
            [all, itemidx, part, value] = line.match regexps.composedkey

            if currentidx is null or currentidx isnt itemidx
                current.dataPoints.add currentdp if currentdp
                currentdp = new DataPoint()

            currentidx = itemidx

            part = part.split ';'
            key = part[0]
            properties = part.splice 1

            value = value.split ';'
            value = value[0] if value.length is 1

            key = key.toLowerCase()

            if key is 'x-ablabel' or key is 'x-abadr'
                value = value.replace '_$!<', ''
                value = value.replace '>!$_', ''
                currentdp.set 'type', value.toLowerCase()
            else
                for property in properties
                    [all, pname, pvalue] = property.match regexps.property
                    currentdp.set pname.toLowerCase(), pvalue.toLowerCase()

                if key is 'adr'
                    value ?= []
                    value = value.join("\n").replace /\n+/g, "\n"

                if key is 'x-abdate'
                    key = 'about'

                if key is 'x-abrelatednames'
                    key = 'other'

                currentdp.set 'name', key.toLowerCase()
                currentdp.set 'value', value.replace "\\:", ":"

        else if regexps.complex.test line
            [all, key, properties, value] = line.match regexps.complex

            current.dataPoints.add currentdp if currentdp
            currentdp = new DataPoint()

            value = value.split ';'
            value = value[0] if value.length is 1

            key = key.toLowerCase()

            if key in ['email', 'tel', 'adr', 'url']
                currentdp.set 'name', key
                if key is 'adr'
                    value ?= []
                    if typeof value isnt 'string'
                        value = value.join '\n'
                    value = VCard.unescapeText value
            else if key is 'photo'
                currentdp = null
                binary = atob value
                buffer = []
                for i in [0..binary.length]
                    buffer.push binary.charCodeAt i
                blobValue = [new Uint8Array(buffer)]
                blob = new Blob blobValue, type: 'image/jpeg'
                current.picture = blob
                continue
            else
                currentdp = null
                continue

            properties = properties.split ';'

            for property in properties
                match = property.match regexps.property
                if match then [all, pname, pvalue] = match
                else
                    pname = 'type'
                    pvalue = property

                if pname is 'type' and pvalue is 'pref'
                    currentdp.set 'pref', 1
                else if pname is 'ENCODING' and pvalue is 'QUOTED-PRINTABLE'
                    value = VCard.unquotePrintable value
                else
                    currentdp.set pname.toLowerCase(), pvalue.toLowerCase()

            currentdp.set 'value', value

    return imported
