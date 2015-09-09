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
        'field:add': 'addField'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:editing', (appModel, value) =>
            @set 'edit', value

        @set
            tel:   []
            email: []
            adr:   []
            xtras: []


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
        type = if type in @defaults.props then type else 'xtras'
        @model.get('datapoints').add
            type:  undefined
            value: ''
            name:  type
