Filtered = BackboneProjections.Filtered
{asciize} = require 'lib/diacritics'


module.exports = class ContactViewModel extends Backbone.ViewModel

    defaults:
        edit:  false
        props: ['tel', 'email', 'adr']
        lists:
            default: ['main', 'work', 'home']
            social:  ['twitter:chat', 'skype:im']
            link:    ['web:url', 'blog:url']

    map:
        ref:        'id'
        avatar:     '_attachments id'
        initials:   'n'
        name:       'n'

    viewEvents:
        'form:addfield': 'addField'
        'sync':          -> @save()
        'before:sync':   'syncDatapoints'


    initialize: ->
        app = require 'application'

        @listenTo app.model, 'change:editing', (appModel, value) =>
            @set 'edit', value

        @['xtras'] = @filterDatapoints null
        for attr in @defaults.props
            @[attr] = @filterDatapoints attr


    toJSON: ->
        datapoints = _.reduce @defaults.props, (memo, attr) =>
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


    filterDatapoints: (filter) ->
        new Filtered @model.get('datapoints'),
            filter: (datapoint) =>
                if filter in @defaults.props
                    datapoint.get('name') is filter
                else
                    not datapoint.get('name') in @defaults.props


    syncDatapoints: (name, collection) ->
        toAdd = _.difference collection, @[name].models
        @model.get('datapoints').add toAdd
