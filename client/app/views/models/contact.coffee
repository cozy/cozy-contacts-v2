{asciize} = require 'lib/diacritics'


module.exports = class ContactViewModel extends Backbone.ViewModel

    map:
        avatar:    'getPictureSrc'
        initials:  'getInitials'
        name:      'splitName'
        phones:    -> @getDatapointsFactory 'tel'
        emails:    -> @getDatapointsFactory 'email'
        addresses: -> @getDatapointsFactory 'adr'
        extras:    -> @getDatapointsFactory 'others'


    getPictureSrc: ->
        if @model.get('_attachments')?.picture
            "/contacts/#{@model.get '_id'}/picture.png"
        else
            null


    getInitials: ->
        [gn, fn, ...] = @model.get('n').split ';'
        """#{if fn then asciize(fn)[0] else '' }\
           #{if gn then asciize(gn)[0] else ''}""".toUpperCase()


    getDatapointsFactory: (type) ->
        _.chain @model.get 'datapoints'
            .filter (point)->
                if type is 'others'
                    not(point.name in ['tel', 'email', 'adr'])
                else
                    point.name is type
            .map (point) -> _.omit point, 'name'
            .value() or []


    splitName: ->
        [gn, fn, mn, pf, sf] = @model.get('n').split ';'
        name =
            first: fn
            given: gn
        name.middle = mn if mn
        name.prefix = pf if pf
        name.suffix = sf if sf
        return name
