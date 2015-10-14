{settings} = require 'config'


module.exports = class SettingsView extends Mn.ItemView

    template: require 'views/templates/settings'

    tagName: 'section'

    className: 'settings'

    attributes:
        role: 'dialog'


    behaviors:
        Dialog: {}

    ui:
        sort: '[name=sort]'


    events:
        'change @ui.sort': 'updateSort'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super, settings, locale: require('imports').locale


    updateSort: (event) ->
        event.preventDefault()
        event.stopPropagation()
        @triggerMethod 'settings:sort', event.currentTarget.value
