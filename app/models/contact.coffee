app = undefined


class Datapoint extends Backbone.Model
    defaults:
        name: 'other'
        type: 'other'
        value: ''
        # The mediatype was introduced with the possibility to share a file
        # with another cloud. It enables us to differentiate an url that
        # represents an e-mail address from that of a cloud.
        mediatype: ''

    parse: (attrs) ->
        if attrs.name is 'adr' and _.isArray attrs.value
            attrs.value = VCardParser.adrArrayToString attrs.value
        return attrs


module.exports = class Contact extends Backbone.Model

    urlRoot: 'contacts'

    defaults:
        n: ';;;;'


    parse: (attrs) ->
        delete attrs[key] for key, value of attrs when value is ''

        if attrs.n
            [gn, fn, ...] = attrs.n.split ';'
            attrs.initials = _.chain [fn, gn]
                .compact()
                .map (name) -> name[0].toAscii()[0]
                .join ''
                .value()

            attrs.sortedName = @_buildSortedName attrs.n

        # (legacy) Once upon a time it was decided that a contact would have a
        # main url address and that address would be used as a means for
        # filtering. To preserve this and, at the same time, to be able to
        # conform to the RFC vCard - https://tools.ietf.org/html/rfc6350 -
        # there is a small manipulation that needs to be done when fetching the
        # data: the url attribute must be converted into a datapoint, hence the
        # following code.
        if (url = attrs.url)
            delete attrs.url
            attrs.datapoints.unshift
                name:  'url'
                type:  'main'
                value: url

        # Ensure Datapoints consistency
        datapoints = @attributes.datapoints or
            new Backbone.Collection attrs.datapoints or [],
                model: Datapoint
                parse: true
        datapoints.comparator = 'name'
        attrs.datapoints = datapoints

        attrs.tags = _.invoke attrs.tags, 'toLowerCase'

        return attrs


    sync: (method, model, options) ->
        avatar = model.get('avatar') or model.get('photo')
        if avatar
            model.unset 'avatar', silent: true
            model.unset 'photo', silent: true

            success = options.success
            # Call savePicture after sync.
            options.success = (data, textStatus, jqXHR) =>
                @savePicture avatar, data,
                    success: =>
                        success.apply @, arguments
                        # SavePicture (neither sync) doesn't update model,
                        # we have to fetch it to get the accurate picture infos
                        @fetch()

                    error: options.error
        super


    validate: (attrs, options) ->
        # Handle specific attributes.
        attrs.fn = VCardParser.nToFN attrs.n.split ';'

        datapoints = (attrs.datapoints?.toJSON() or [])
        attrs.datapoints = datapoints.map (point) ->
            if point.name is 'adr'
                point.value = VCardParser.adrStringToArray point.value
            return point

        # (legacy, see comments in "parse" function) The condition to decide if
        # an e-mail address can be the main url is: it must be an url and it's
        # mediatype is empty. Indeed if an url has a mediatype it means that
        # it's not an e-mail but the address of a cloud.
        mainUrl = _.findWhere attrs.datapoints, {name: 'url', mediatype: ''}
        if mainUrl
            attrs.datapoints = _.without attrs.datapoints, mainUrl
            attrs.url = mainUrl.value

        # When the user selects in the dropdown list for other information the
        # field "cozy cloud" we need to change some attributes of the
        # corresponding datapoint in order to respect the vCard RFC.
        # The changes are:
        # name: 'share' -> name: 'url' + mediatype: 'cloud:cozy'
        clouds = _.where attrs.datapoints, {name: 'share'}
        if not _.isEmpty(clouds)
            for cloud in clouds
                cloud.name      = 'url'
                cloud.mediatype = 'cloud:cozy'

        options.attrs = attrs
        false


    _buildSortedName: (n) ->
        n ?= @get 'n'

        sortKey = app.model.get 'sort'
        [gn, fn, mn, ...] = n.split ';'

        _.chain if sortKey is 'fn' then [fn, mn, gn] else [gn, fn, mn]
            .compact()
            .join ' '
            .value()


    constructor: ->
        app = require 'application'
        super


    initialize: ->
        @listenTo app.model, 'change:sort': ->
            @set 'sortedName': @_buildSortedName()


    toString: (opts = {}) ->
        [gn, fn, mn, pf, sf] = @attributes.n.split ';'
        # wrap given name (at index 0) in pre/post tags if provided
        gn = _.compact([opts.pre, gn, opts.post]).join ''
        _.compact([pf, fn, mn, gn, sf]).join ' '


    # We override toJSON to ensure the exported object is the a true object.
    # Allow a options.toVCF boolean to sanitize the output before.
    toJSON: (options) ->
        _.extend super, datapoints: @attributes.datapoints.toJSON()


    toHighlightedString: (pattern, opts= {})->
        format = if opts.format
            pre: '»'
            post: '«'
        else undefined

        name  = @toString format
        match = fuzzy.match pattern, name, opts if pattern

        res = if match then match.rendered else name

        if format
            res = res
                .replace '»', opts.format.pre
                .replace '«', opts.format.post

        return res


    match: (pattern, opts = {}) ->
        # default search to name and org only
        targets = _.compact [@toString(), @attributes.org]

        if opts.fullsearch
            # Get all datapoints but addresses
            points = _.compact @attributes.datapoints.map (item) ->
                item.get 'value' unless item.get('name') is 'adr'

            # Mix'em with previous targets and tags
            targets = targets
                .concat(points)
                .concat @attributes.tags
        score = targets.reduce (memo, target, index) ->
            # Fuzzy does not check if target is a string before calling
            # toLowerCase().
            # See https://github.com/cozy/cozy-contacts/issues/259
            return memo unless typeof target is 'string'
            res = fuzzy.match pattern, target
            return memo + (res?.score or 0)
        , 0

        return score or false


    savePicture: (imgData, attrs, options) ->
        unless attrs.id
            return options.error new Error 'Model should have been saved once.'

        #transform into a blob
        binary = atob imgData
        array = []
        for i in [0..binary.length]
            array.push binary.charCodeAt i

        blob = new Blob [new Uint8Array(array)], type: 'image/jpeg'

        data = new FormData()
        data.append 'picture', blob
        data.append 'contact', attrs

        $.ajax
            type: 'PUT'
            url: "contacts/#{attrs.id}/picture"
            data: data
            contentType: false
            processData: false
            success: options.success
            error: options.error


    picturetoa: (callback) ->
        return callback() unless @attributes._attachments?.picture
        picture = new Image()
        picture.onload = ->
            canvas = document.createElement 'canvas'
            canvas.width = @naturalWidth
            canvas.height = @naturalHeight
            ctx = canvas.getContext '2d'
            ctx.drawImage @, 0, 0
            [..., base64string] = canvas.toDataURL("image/jpeg").split ','
            callback base64string
        picture.src = "contacts/#{@id}/picture.png"


    toVCF: (callback) ->
        data = @toJSON()

        # Because viewModel call uses the saveAs method, that broke console
        # messages, we wrap it in a try..catch (which is a better solution,
        # anyway), because catch actions are executed asynchronously.
        try
            # We remove the BDay datapoint if it doesn't match ISO 8601
            unless moment(data.bday, 'YYYY-MM-DD', true).isValid()
                delete data['bday']
                throw new Error "Malformed bday for #{data.id}"
        catch err
            console.error err

        @picturetoa (picture) -> callback VCardParser.toVCF data, picture


    # Return a string containing last and first name of the contact.
    # It's useful for sorting.
    getLastAndFirstNames: ->
        name = @get('n').split(';')
        return "#{name[1]}#{name[0]}"
