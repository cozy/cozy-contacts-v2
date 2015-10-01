ContactViewModel = require 'views/models/contact'


module.exports = class Group extends Mn.CompositeView

    template: require 'views/templates/contacts/group'

    tagName: 'dl'

    className: ->
        return 'empty' if @model.get 'isEmpty'


    childViewContainer: 'ul'

    childView: require 'views/contacts/row'

    childViewOptions: (model) ->
        model: new ContactViewModel {}, model: model


    modelEvents:
        'change:isEmpty': 'toggleEmpty'


    toggleEmpty: ->
        @$el.toggleClass 'empty', @model.get 'isEmpty'
