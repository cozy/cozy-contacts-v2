CONFIG = require('config').contact


module.exports = class ContactXtrasView extends Mn.ItemView

    tagName: ->
        if @model.get 'edit' then 'fieldset' else 'ul'

    template: require 'views/templates/contacts/components/xtras'


    modelEvents: ->
        _.reduce CONFIG.xtras, (memo, prop) ->
            memo["change:#{prop}"] = (args...) ->
                @render.apply @, args
                @setFocus.apply @, args
            return memo
        , {}


    serializeData: ->
        edit: @model.get 'edit'
        ref: @model.get 'ref'
        xtras: _.reduce CONFIG.xtras, (memo, prop) =>
            memo[prop] = @model.get prop if @model.has prop
            return memo
        , {}


    setFocus: (model) ->
        ref   = @model.get 'ref'
        field = _.keys(model.changed)[0]
        @$("##{field}-#{ref}").trigger 'focus'

