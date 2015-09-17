Filtered = BackboneProjections.Filtered
{asciize} = require 'lib/diacritics'

CONFIG = require('config').contact


module.exports = class ContactViewModel extends Backbone.ViewModel

    defaults:
        edit:  false

    map:
        ref:        'id'
        avatar:     '_attachments id'
        initials:   'n'
        name:       'n'

    viewEvents:
        'form:addfield': 'addField'
        'form:submit':   -> @save()
        'edit:cancel':   'reset'
        'delete':        -> @destroy()


    initialize: ->
        app = require 'application'

        @['xtras'] = @filterDatapoints null
        for attr in CONFIG.datapoints.main
            @[attr] = @filterDatapoints attr


    toJSON: ->
        datapoints = _.reduce CONFIG.datapoints.main, (memo, attr) =>
            memo[attr] = @[attr].toJSON()
            return memo
        , xtras: @xtras.toJSON()
        _.extend {}, super, datapoints


    getMappedRef: (id) ->
        id.slice 0, 6


    getMappedAvatar: (attachments, id) ->
        if attachments?.picture
            "/contacts/#{id}/picture.png"
        else
            null


    getMappedInitials: (n) ->
        [gn, fn, ...] = n.split ';'
        """#{if fn then asciize(fn)[0] else '' }\
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
        name = @get 'name'
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
