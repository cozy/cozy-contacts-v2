CompareContacts = require "lib/compare_contacts"


# Collection of merge ViewModels.
# Automatically feed up with findSimilars algorythme.
module.exports = class Duplicates extends Backbone.Collection

    model: require 'views/models/merge'

    # Local collection
    url: null

    # Initialize the collection with duplicates fund in the sepcified contacts
    # collection.
    findDuplicates: (collection) ->
        duplicates = CompareContacts.findSimilars collection.toJSON()
        duplicates.forEach (candidates) =>
            candidates = candidates.map (c) -> collection.get c.id

            # Create a merge ViewModel and add it to the collection,
            # initialize with the specified candidates ContactsViewModels.
            @add { candidates }
