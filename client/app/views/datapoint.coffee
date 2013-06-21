BaseView = require 'lib/base_view'

module.exports = class DataPointView extends BaseView

    template: require 'templates/datapoint'

    tagName: 'li'
    className: 'datapoint'

    events: ->
        'blur .type'     : 'store'
        'blur .value'    : 'store'

    getRenderData: ->
        _.extend @model.toJSON(), placeholder: @getPlaceHolder()

    afterRender: ->
        @valuefield = @$('.value')
        @typefield  = @$('input.type')
        @typefield.typeahead source: @getPossibleTypes

    getPossibleTypes: =>
        # TODO : replace me with something smart, like most often used
        # TODO : i18n ...
        switch @model.get 'name'
            when 'about' then ['org', 'birthday', 'title']
            when 'other' then ['skype', 'jabber', 'irc']
            else ['main', 'home', 'work', 'assistant']

    getPlaceHolder: ->
        switch @model.get 'name'
            when 'email' then 'john.smith@example.com'
            when 'adr' then '42 main street ...'
            when 'tel' then '+33 1 23 45 67 89'
            when 'url' then 'http://example.com/john-smith'
            when 'about', 'other' then t 'type here'

    store: ->
        @model.set
            type: @typefield.val()
            value: @valuefield.val()
