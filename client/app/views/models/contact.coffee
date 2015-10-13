Filtered = BackboneProjections.Filtered
{asciize} = require 'lib/diacritics'

CONFIG = require('config').contact


module.exports = class ContactViewModel extends Backbone.ViewModel

    defaults:
        new:  false
        edit: false

    map:
        avatar:     '_attachments'
        initials:   'n'
        name:       'n'


    events:
        save:  'onSave'
        reset: 'onReset'

    viewEvents:
        'form:field:add': 'addField'
        'form:submit':    -> @save()
        'edit:cancel':    'reset'
        'delete':         -> @destroy()


    proxy: ['toString', 'match']


    initialize: ->
        @onReset()

        @['xtras'] = @filterDatapoints null
        for attr in CONFIG.datapoints.main
            @[attr] = @filterDatapoints attr


    toJSON: ->
        datapoints = _.reduce CONFIG.datapoints.main, (memo, attr) =>
            memo[attr] = @[attr].toJSON()
            return memo
        , xtras: @xtras.toJSON()
        _.extend {}, super, datapoints


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
            attrs.avatar = avatar
        return attrs


    getMappedInitials: (n) ->
        [gn, fn, ...] = n.split ';'
        """#{if fn then asciize(fn)[0] else ''}\
           #{if gn then asciize(gn)[0] else ''}""".toUpperCase()


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


    addField: (type) ->
        @set type, '' if type in CONFIG.xtras


    filterDatapoints: (filter) ->
        new Filtered @model.get('datapoints'),
            filter: (datapoint) ->
                if filter in CONFIG.datapoints.main
                    datapoint.get('name') is filter
                else
                    datapoint.get('name') not in CONFIG.datapoints.main


    syncDatapoints: (name, collection) ->
        datapoints = @model.get 'datapoints'
        datapoints.remove _.difference @[name].models, collection
        datapoints.add _.difference collection, @[name].models


    onSave: ->
        if @get 'new'
            app = require 'application'
            app.contacts.add @model


    onReset: ->
        @set 'ref', @model.cid
