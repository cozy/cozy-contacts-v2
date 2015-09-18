ConfirmView = require 'lib/views/confirm'


module.exports = class Confirm extends Mn.Behavior

    ui:
        confirms: '[data-confirm]'

    events:
        'click @ui.confirms': 'confirm'


    initialize: (options) ->
        @events = _.extend {}, @events, @_buildTriggers()


    confirm: (event) ->
        event.preventDefault()
        event.stopPropagation()

        cfg = @$(event.currentTarget).data('confirm')
        @_triggerView cfg


    _buildTriggers: ->
        view = @view

        _.reduce @options.triggers, (memo, value, eventName) ->
            options = _.defaults {}, value,
                preventDefault:  true
                stopPropagation: true

            memo[eventName] = (event) ->
                if event
                    if event.preventDefault and options.preventDefault
                        event.preventDefault()
                    if event.stopPropagation and options.stopPropagation
                        event.stopPropagation()

                cfg = _.pick options, 'title', 'message', 'btn_ok', 'btn_cancel'
                confirmView = @_triggerView cfg
                @listenToOnce confirmView, 'confirm:true', ->
                    view.triggerMethod options.event

            return memo
        , {}


    _triggerView: (cfg) ->
        app         = require 'application'
        confirmView = new ConfirmView model: new Backbone.Model cfg

        Mn.bindEntityEvents @, confirmView,
            'confirm:true':  -> @view.triggerMethod 'confirm:true'
            'confirm:close': -> @view.triggerMethod 'confirm:close'

        app.layout.showChildView 'alerts', confirmView
        return confirmView
