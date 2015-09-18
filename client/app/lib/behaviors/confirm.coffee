ConfirmView = require 'lib/views/confirm'


module.exports = class Confirm extends Mn.Behavior

    # ui:
    #     trigger: '[data-confirm]'
    #
    # events:
    #     'click @ui.trigger': 'confirm'


    initialize: (options) ->
        @events = _.extend {}, @events, @_buildTriggers()


    confirm: (event) ->
        console.debug event.currentTarget.dataset.confirm


    _buildTriggers: ->
        view = @view
        _.reduce @options.triggers, (memo, value, eventName) ->
            memo[eventName] = ->
                app   = require 'application'
                cfg   = _.pick value, 'title', 'message', 'btn_ok', 'btn_cancel'
                app.layout.showChildView 'alerts', new ConfirmView
                    success: -> view.triggerMethod value.event
                    model:   new Backbone.Model cfg

            return memo
        , {}
