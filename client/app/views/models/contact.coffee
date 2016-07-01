Filtered = BackboneProjections.Filtered

CONFIG = require('config').contact
CH = require('lib/contact_helper')

app = null


module.exports = class ContactViewModel extends Backbone.ViewModel

    defaults:
        new:  false
        edit: false

    map:
        avatar: '_attachments'
        name:   'n'


    events:
        'before:save': 'syncDatapoints'
        save:          'onSave'
        reset:         'onReset'

    viewEvents:
        'edit:cancel':    'reset'
        'tags:update':    'updateTags'
        'tags:add':       'addNewTag'
        'form:field:add': 'onAddField'
        'form:submit':    _.ary @::save, 0
        'export':         'downloadAsVCF'
        'delete':         _.ary @::destroy, 0


    proxy: ['toString', 'toHighlightedString', 'match']


    initialize: ->
        app = require 'application'

        @_setRef()

        @getDatapoints = _.memoize @getDatapoints, (key) ->
            if @attributes.edit then "edit-#{key}" else key

        @listenTo @, 'change:edit', (contactViewModel, edit) ->
            return unless edit
            cache = @getDatapoints.cache
            delete cache[key] for key of cache when /^edit/.test key


    toJSON: ->
        data = super
        delete data.datapoints
        data.xtras = @getDatapoints('xtras').toJSON()
        _.reduce CONFIG.datapoints.main, (memo, attr) =>
            memo[attr] = @getDatapoints(attr).toJSON()
            return memo
        , data


    getMappedAvatar: (attachments) ->
        if attachments?.picture
            return "contacts/#{@model.id}/picture.png" +
                # Force refresh on change picture with dummy parameter.
                "?revpos=#{attachments.picture.revpos}"
        else
            null


    saveMappedAvatar: ->
        attrs = {}
        avatar = @get 'avatar'
        if avatar? and not avatar.match(/contacts\/.+\/picture.png/)?
            attrs.avatar = avatar.split(',')[1]
        return attrs


    getMappedName: (n) ->
        [gn, fn, mn, pf, sf] = n.split ';'
        name =
            first: fn
            given: gn
        name.middle = mn if mn
        name.prefix = pf if pf
        name.suffix = sf if sf
        return name


    saveMappedName: ->
        name = _.clone(@get 'name')
        (attrs = {})['n'] = [
            name.given
            name.first
            name.middle
            name.prefix
            name.suffix
        ].join ';'
        return attrs


    _setRef: ->
        @set 'ref', @model.cid


    getIndexKey: ->
        sortIdx = if app.model.get('sort') is 'fn' then 0 else 1
        initial = @get('initials')[sortIdx]?.toLowerCase() or ''
        if /[a-z]/.test initial then initial else '#'


    onAddField: (type) ->
        @set type, '' if type in CONFIG.xtras


    getDatapoints: (name) ->
        filter = (datapoint) ->
            if name in CONFIG.datapoints.main
                datapoint.get('name') is name
            else
                datapoint.get('name') not in CONFIG.datapoints.main

        if @attributes.edit
            models = @model.get 'datapoints'
            .filter filter
            .map (model) -> model.clone()
            new Backbone.Collection models
        else
            new Filtered @model.get('datapoints'), filter: filter


    # Extract datapoints from the view model to store them in the data model.
    syncDatapoints: ->

        # The getDatapoints function has been memoized, it means it keeps all
        # its returned values in a cache.
        # Here we deal directly with this cache because this function has
        # already been called for all fields and edited fields were already
        # marked.
        cache      = @getDatapoints.cache
        datapoints = @model.get 'datapoints'

        # It grabs all datapoints that has been edited.
        models = []
        for key, collection of cache.__data__ when /^edit/.test key
            models = models.concat CH.getNonEmptyDatapoints collection

        # Load new datapoints in the data model.
        datapoints.reset models


    # Save directly new tags to the server if the model is already created.
    # If the model is not created (has no id yet), it just updates the tags
    # attribute to avoid conflicts during the creation process.
    updateTags: (tags) ->
        if @model.id?
            @model.save tags: tags
        else
            @model.set tags: tags


    addNewTag: (tag) ->
        {contacts, tags} = app

        tags.create
            name: tag
        ,
            wait: true
            success: =>
                tags = _.clone(@model.get('tags')).concat tag
                @updateTags tags


    onSave: ->
        app.contacts.add @model if @get 'new'


    onReset: -> @_setRef()


    downloadAsVCF: ->
        fn = @model.get 'fn'
        @model.toVCF (card) ->
            blob = new Blob [card], type: "text/plain;charset=utf-8"
            saveAs blob, "#{fn}.vcf"
