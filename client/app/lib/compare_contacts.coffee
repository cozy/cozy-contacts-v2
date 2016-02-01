ContactHelper = require 'lib/contact_helper'

module.exports = CC = {}

# Find similar contacts methods.

CC.isSamePerson = (contact1, contact2) ->
    return contact1.fn is contact2.fn and contact1.datapoints.some (field) ->
        if field.name in ['tel', 'adr', 'email', 'chat']
            hasField field, contact2
        else false


# Names have similarities regardless :
# - special chars,
# - case insensitive,
# - lastname - firstname order.
CC.mayBeSamePerson = (contact1, contact2) ->
    return compareN(contact1.n, contact2.n) > 0


# Group similars contacts together. The comparison is based on the couple
# first name and last name. If the couple matches for two contacts they
# are considered as similars.
# A contact can be in only one group.
CC.findSimilars = (contacts) ->
    similars = []

    # We used a map here to make
    names = {}
    for contact in contacts

        # Get first and last name and make comparison insensitive to special
        # chars.
        [lastName, firstName, dummy, dummy, dummy] = contact.n.split ';'
        lastName  = lastName.toAscii().toLowerCase()
        firstName = firstName.toAscii().toLowerCase()

        # Check if John Doe is already listed.
        if names["#{firstName} #{lastName}"]?
            names["#{firstName} #{lastName}"].push contact

        # Check if Doe John is already listed.
        else if names["#{lastName} #{firstName}"]?
            names["#{lastName} #{firstName}"].push contact

        # Else register the contact by setting a key based on
        # his/her first and last names
        else if "#{firstName} #{lastName}".length > 1
            names["#{firstName} #{lastName}"] = []
            names["#{firstName} #{lastName}"].push contact

    # Every keys that is linked with an array of length superior at two is
    # considered has a name for which there are contacts to merge.
    similars = Object.keys(names)
        .filter (key) -> return names[key].length > 1
        .map (name) -> return names[name]

    return similars


# Merge methods


# Merge cozy contact toMerge in base.
# Mess up toMerge contact during the process.
CC.mergeContacts = (base, toMerge) ->
    toMerge.datapoints.forEach (field) ->
        unless hasField field, base, true
            base.datapoints.push field

    delete toMerge.datapoints

    if toMerge.accounts?
        toMerge.accounts.forEach (account) ->
            unless ContactHelper.hasAccount(base, account.type, account.name)
                ContactHelper.setAccount base, account

        delete toMerge.accounts

    base.tags = _union base.tags, toMerge.tags
    delete toMerge.tags

    if toMerge.note? and toMerge.note isnt '' and
    base.note? and base.note isnt ''
        base.note += "\n" + toMerge.note
    delete toMerge.note

    base = _extend base, toMerge

    return base


# # # # # # # # # # # #

# # #
# Tools

# Check if (cozy)contact fuzzily has the specified field
hasField = (field, contact, checkType = false) ->
    return false unless field.value?

    contact.datapoints.some (baseField) ->
        if field.name is baseField.name and
        (not checkType or checkType and field.type is baseField.type) and
        baseField.value?

            if field.name is 'tel'
                return field.value.replace(/[-\s]/g, '') is baseField
                    .value.replace(/[-\s]/g, '')

            else if field.name is 'adr'
                same = true
                i = 0
                while same and i < 7
                    same = same and field.value[i] is baseField.value[i] or
                    field.value[i] is "" and not baseField.value[i]? or
                    not field.value?[i] and baseField.value[i] is ""
                    i++

                return same

            else
                return field.value is baseField.value

        else
            return false


_union = (a, b) ->
    a = a or []
    b = b or []
    return a.concat b.filter (item) -> return a.indexOf(item) < 0

_extend = (a, b) ->
    for k, v of b
        if v?
            a[k] = v
    return a
