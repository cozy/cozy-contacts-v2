module.exports = class SearchView extends Mn.ItemView

    template: require 'views/templates/tools/search'

    tagName: 'form'


    onShow: ->
        @$el.find('input').focus()
