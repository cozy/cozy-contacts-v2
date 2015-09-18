# ContactCollection
# is a collection of Contacts (models/contact)
# define the endpoint where Backbone will fetch the list of contacts

module.exports = class ContactCollection extends Backbone.Collection

    model: require 'models/contact'
    url: 'contacts'

    #sort by names
    comparator: (a,b) ->
        nameA = a.getDisplayName().replace(/\ /g, '').toLowerCase()
        nameB = b.getDisplayName().replace(/\ /g, '').toLowerCase()
        compare = nameA.localeCompare nameB
        out = if compare > 0 then 1
        else if compare < 0 then -1
        else 0

    # auto resort when contact name change
    initialize: ->
        super
        @on 'change:fn', => @sort()
        @on 'change:n' , => @sort()

    getTags: ->
        out = window.tags or []
        @each (contact) -> out = out.concat contact.get 'tags'
        return _.unique out
