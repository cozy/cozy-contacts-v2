CompareContacts = require "lib/compare_contacts"
ContactViewModel = require 'views/models/contact'

module.exports = class Duplicates extends Backbone.Collection

    model: require 'views/models/merge'

    url: null

    findDuplicates: (collection) ->
        duplicates = CompareContacts.findSimilars collection.toJSON()
        duplicates.forEach (candidates) =>
            candidates = candidates.map (c) ->
                new ContactViewModel {
                    new: false
                }, {
                    model: collection.get c.id
                }

            @add { candidates }
