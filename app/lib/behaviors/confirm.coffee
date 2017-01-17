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

        config = @$(event.currentTarget).data('confirm')
        @_triggerView config


    _buildTriggers: ->

        # The view here correspond to the view handling the behavior. It is not
        # the confirm dialog view.
        view = @view

        _.reduce @options.triggers, (memo, opts, eventName) ->
            _buildOptions = ->
                _.defaults {}, (if _.isFunction opts then opts() else opts),
                    preventDefault:  true
                    stopPropagation: true

            options = _buildOptions() unless _.isFunction opts

            memo[eventName] = (event) ->
                options = _buildOptions() if _.isFunction opts

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

        # Build the confirm dialog view from configuration given by the calling
        # widget.
        viewOpts    = _.pick(
            cfg, 'title', 'message', 'btn_ok', 'btn_cancel', 'end_event')
        confirmView = new ConfirmView model: new Backbone.Model viewOpts

        @view.$el.attr 'aria-busy', true

        Mn.bindEntityEvents @, confirmView,
            'confirm:close': ->
                # Close confirm dialog view when close button is clicked.
                @view.$el.attr 'aria-busy', false
                @view.triggerMethod 'confirm:false'
            'confirm:true':  ->
                @view.triggerMethod cfg.event if cfg.event

                # Show loader until end_event is fired. Then closes the
                # confirm dialog view.
                if viewOpts.end_event
                    confirmView.showLoading()
                    app.model.on viewOpts.end_event, =>
                        @view.$el.attr 'aria-busy', false
                        @view.triggerMethod 'confirm:true'
                        app.model.off viewOpts.end_event
                        confirmView.close()

                # Close confirm dialog view when ok button is clicked and
                # when no long processing is running after.
                else
                    @view.$el.attr 'aria-busy', false
                    @view.triggerMethod 'confirm:true'
                    confirmView.close()

        app.layout.showChildView 'alerts', confirmView
        return confirmView


