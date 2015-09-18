BaseView       = require 'lib/base_view'
app            = require 'application'

module.exports = class ContactName extends BaseView

    template: require 'templates/contact_name'

    el: '#contact-name'

    events:
        'keyup input': 'onKeyup'
        'blur input': 'onBlur'
        'click #toggle-name-fields': 'toggleFields'
        'click #toggle-name': 'toggleName'

    constructor: (options) ->
        super options
        @contactWidget = options.contactWidget

    afterRender: ->
        @toggleFields()

    toggleFields: ->
        nparts = @model.get 'n'
        full = _.reject(nparts, _.isEmpty).length is nparts.length
        toggleButton = @$('#toggle-name-fields')
        if toggleButton.hasClass('fa-minus') and not full
            @showFew()
            toggleButton.toggleClass 'fa-plus fa-minus'
        else if toggleButton.hasClass('fa-plus')
            @showAll()
            toggleButton.toggleClass 'fa-plus fa-minus'


    showFew: ->
        nameParts = _.object ['last', 'first', 'middle', 'prefix', 'suffix'],
        @model.get 'n'

        for field, value of nameParts
            elem = @$('.control-group.' + field)
            if (field in ['last', 'first']) or (value? and value isnt '')
                elem.show()
            else
                elem.hide()

    showAll: ->
        fields = ['last', 'first', 'middle', 'prefix', 'suffix']
        fields.forEach (field) =>
            @$('.control-group.' + field).show()

    setName: =>
        nameParts = _.object ['last', 'first', 'middle', 'prefix', 'suffix'],
                @model.get 'n'

        for field, value of nameParts
            @$('input#' + field).val value

    getRenderData: ->
        _.extend {}, @model.attributes,
            fn: @model.get 'fn'
            n: @model.get 'n'

    getStructuredName: ->
        fields = ['last', 'first', 'middle', 'prefix', 'suffix']
        return fields.map (field) -> $('#' + field).val()

    onKeyup: (ev) ->
        @options.onKeyup ev

    onBlur: (ev) ->
        @options.onBlur ev

    toggleName: ->
        @contactWidget.toggleContactName()
