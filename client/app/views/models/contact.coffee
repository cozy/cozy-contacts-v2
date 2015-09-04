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
        ref:        'getRef'
        avatar:     'getPictureSrc'
        initials:   'getInitials'
        name:       'splitName'
        datapoints: 'filterDatapoints'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:editing', (appModel, value)=>
            @set 'edit', value


    getRef: ->
        @model.id.slice 0, 6


    getPictureSrc: ->
        if @model.get('_attachments')?.picture
            "/contacts/#{@model.get '_id'}/picture.png"
        else
            null


    getInitials: ->
        [gn, fn, ...] = @model.get('n').split ';'
        """#{if fn then asciize(fn)[0] else '' }\
           #{if gn then asciize(gn)[0] else ''}""".toUpperCase()


    splitName: ->
        [gn, fn, mn, pf, sf] = @model.get('n').split ';'
        name =
            first: fn
            given: gn
        name.middle = mn if mn
        name.prefix = pf if pf
        name.suffix = sf if sf
        return name


    filterDatapoints: ->
        _.chain @model.get 'datapoints'
        .groupBy (point) =>
            if point.name in @defaults.props then point.name else 'xtras'
        .value() or []
