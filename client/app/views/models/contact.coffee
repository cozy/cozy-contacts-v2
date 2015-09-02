{asciize} = require 'lib/diacritics'


module.exports = class ContactViewModel extends Backbone.ViewModel

    defaults:
        edit: false

    map:
        avatar:     'getPictureSrc'
        initials:   'getInitials'
        name:       'splitName'
        datapoints: 'filterDatapoints'


    initialize: ->
        app = require 'application'
        @listenTo app.model, 'change:editing', (appModel, value)=>
            @set 'edit', value


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
        groups =
            tel:   'phones'
            email: 'emails'
            adr:   'addresses'

        _.chain @model.get 'datapoints'
        .groupBy (point) ->
            if point.name in ['tel', 'email', 'adr']
                groups[point.name]
            else 'xtras'
        .value() or []
