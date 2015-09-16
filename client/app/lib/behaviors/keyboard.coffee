module.exports = class Keyboard extends Mn.Behavior

    defaults:
        eventName: 'keydown'

    events: ->
        return unless @options.keymaps

        events = {}
        keyEvents = _.mapObject @options.keymaps, @_buildKeyboardTrigger
        events[@options.eventName] = (event) =>
            key = event.which.toString()
            return unless key in _.keys keyEvents
            keyEvents[key].call @, event
        return events


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
            @view.triggerMethod eventName, event
