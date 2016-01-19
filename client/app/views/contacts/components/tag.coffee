module.exports = class ContactTagView extends Mn.ItemView

    tagName: 'li'

    template: require 'views/templates/contacts/components/tag'


    serializeData: ->
        tags = @options.contactViewModel.get('tags')
        _.extend {}, super, selected: _.includes tags, @model.get 'name'
