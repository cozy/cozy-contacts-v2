BaseView = require 'lib/base_view'

module.exports = class DocView extends BaseView

    id: 'doc'
    template: require 'templates/doc'

    events:
        'change #nameFormat': 'saveNameFormat'
        'click #show-password': 'showPassword'
        'click #hide-password': 'hidePassword'

    getRenderData: ->
        account: @model

    initialize: ->
        @model = window.webDavAccount
        if @model?
            @model.placeholder = @getPlaceholder @model.token

    afterRender: ->
        if app.config.get('nameOrder') isnt 'not-set'
            @$('#nameFormat').val app.config.get 'nameOrder'


    saveNameFormat: ->
        help = @$('.help-inline').show().text t 'saving'
        app.config.save nameOrder: @$('#nameFormat').val(),
            wait: true
            success: ->
                help.text(t 'saved').fadeOut()
                window.location.reload()

            error: ->
                help.addClass('error').text t 'server error occured'

    # creates a placeholder for the password
    getPlaceholder: (password) ->
        placeholder = []
        placeholder.push '*' for i in [1..password.length] by 1
        return placeholder.join ''

    showPassword: ->
        @$('#placeholder').html @model.token
        @$('#show-password').hide()
        @$('#hide-password').show()

    hidePassword: ->
        @$('#placeholder').html @model.placeholder
        @$('#hide-password').hide()
        @$('#show-password').show()
