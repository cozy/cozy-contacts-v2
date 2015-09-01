module.exports = class Keyboard extends Mn.Behavior

    defaults:
        eventName: 'keydown'


    initialize: ->
        @listenTo @view, 'render', @configureKeyEvents


    configureKeyEvents: ->
        triggers = _.result @view, 'keymaps'
        return unless triggers

        events = {}
        keyEvents = _.mapObject triggers, @_buildKeyboardTrigger
        events[@defaults.eventName] = (event) =>
            key = event.which.toString()
            return unless key in _.keys keyEvents
            keyEvents[key].call @, event

        Backbone.View.prototype.delegateEvents.call @view, events


    _buildKeyboardTrigger: (triggerDef) ->
        hasOptions = _.isObject triggerDef
        options = _.defaults {}, (if hasOptions then triggerDef else {}),
            preventDefault: true
            stopPropagation: true
        eventName = if hasOptions then options.event else triggerDef

        (event) ->
            if event
                if event.preventDefault and options.preventDefault
                    event.preventDefault()
                if event.stopPropagation and options.stopPropagation
                    event.stopPropagation()

            @triggerMethod.call @view, eventName
