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

                confirmView = @_triggerView options

            return memo
        , {}


    _triggerView: (cfg) ->
        app         = require 'application'
        viewOpts    = _.pick cfg, 'title', 'message', 'btn_ok', 'btn_cancel'
        confirmView = new ConfirmView model: new Backbone.Model viewOpts

        @view.$el.attr 'aria-busy', true

        Mn.bindEntityEvents @, confirmView,
            'confirm:close': ->
                @view.$el.attr 'aria-busy', false
                @view.triggerMethod 'confirm:close'
            'confirm:true':  ->
                @view.triggerMethod 'confirm:true'
                @view.triggerMethod cfg.event if cfg.event

        app.layout.showChildView 'alerts', confirmView
        return confirmView
