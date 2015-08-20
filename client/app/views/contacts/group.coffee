ContactViewModel = require 'views/models/contact'

ContactView = require 'views/contacts/row'


module.exports = class Group extends Mn.CompositeView

    template: require 'views/templates/contacts/group'

    tagName: 'dl'

    childViewContainer: 'ul'

    childView: ContactView

    childViewOptions: (model) ->
        model: new ContactViewModel {}, model: model


    modelEvents:
        'change:isEmpty': 'toggleEmpty'


    initialize: ->
        @on 'render:template', @toggleEmpty


    toggleEmpty: ->
        @$el.toggleClass 'empty', @model.get 'isEmpty'
