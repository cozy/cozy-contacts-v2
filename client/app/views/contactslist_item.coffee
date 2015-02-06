BaseView = require 'lib/base_view'

module.exports = class ContactsListItemView extends BaseView

    tagName: 'a'
    className: 'contact-thumb'
    attributes: -> 'href': "#contact/#{@model.id}"

    initialize: ->
        @listenTo @model, 'change', @render

    getRenderData: ->
        _.extend {},  @model.toJSON(),
          hasPicture: not not @model.get('pictureRev')
          bestmail:   @model.getBest 'email'
          besttel:    @model.getBest 'tel'
          displayName:       @model.getDisplayName()
          timestamp: Date.now()

    template: require 'templates/contactslist_item'
