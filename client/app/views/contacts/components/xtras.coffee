CONFIG = require('config').contact


module.exports = class ContactXtrasView extends Mn.ItemView

    tagName: ->
        if @model.get 'edit' then 'div' else 'ul'

    template: require 'views/templates/contacts/components/xtras'


    initialize: ->
        @listenTo @model, "change:#{prop}", @render for prop in CONFIG.xtras


    serializeData: ->
        edit: @model.get 'edit'
        xtras: _.reduce CONFIG.xtras, (memo, prop) =>
            memo[prop] = @model.get prop if @model.has prop
            return memo
        , {}
