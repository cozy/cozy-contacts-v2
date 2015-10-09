diacritics = require 'lib/diacritics'

module.exports = CC = {}

# Find similar contacts methods.

CC.isSamePerson = (contact1, contact2) ->
    return contact1.fn is contact2.fn and
        contact1.datapoints.some (field) ->
            if field.name in ['tel', 'adr', 'email', 'chat']
                return hasField field, contact2
            else
                return false

# Names have similarities regardless :
# - special chars,
# - case insensitive,
# - lastname - firstname order.
CC.mayBeSamePerson = (contact1, contact2) ->
    return compareN(contact1.n, contact2.n) > 0


# Group similars contacts together.
# A contact can be in only one group.
CC.findSimilars = (contacts) ->
    viewed = {}
    similars = []
    for contact in contacts
        viewed[contact._id] = true
        similar = [contact]
        for contact2 in contacts
            if contact2._id not of viewed and
            CC.mayBeSamePerson(contact, contact2)
                # console.log 'similar !'
                viewed[contact2._id] = true
                similar.push contact2

        if similar.length > 1
            similars.push similar

    return similars



# Merge methods


# Merge cozy contact toMerge in base.
# Mess up toMerge contact during the process.
CC.mergeContacts = (base, toMerge) ->
    toMerge.datapoints.forEach (field) ->
        unless hasField field, base, true
            base.datapoints.push field

    delete toMerge.datapoints

    base.tags = _union base.tags, toMerge.tags
    delete toMerge.tags

    if toMerge.note? and toMerge.note isnt '' and
    base.note? and base.note isnt ''
        base.note += "\n" + toMerge.note
    delete toMerge.note

    base = _extend base, toMerge


    return base


# Return the merge which would be automatically done.
# for fields, true means use right, false means use left.
# leftDatapoints and rightDatapoints: true means keep this index.
CC.mergePlan = (left, right) ->
    plan =
        left: left
        right: right

    plan.leftDatapoints = []

    for field in left.datapoints
        plan.leftDatapoints.push true

    plan.rightDatapoints = []
    for field in right.datapoints
        plan.rightDatapoints.push not hasField(field, left, true)

    # Pay attention to tags !

    for k, v of left
        plan[k] = false

    for k, v of right
        if k of plan
            continue

        else
            plan[k] = true

    delete plan.datapoints
    delete plan.tags

    return plan

# Merge right into left, accordingly with specified plan.
CC.applyMergePlan = (left, right, plan) ->
    datapoints = []
    for keep, i in plan.leftDatapoints
        if keep
            datapoints.push left.datapoints[i]

    for keep, i in plan.rightDatapoints
        if keep
            datapoints.push right.datapoints[i]

    tags = _union left.tags, right.tags

    for k, v of plan
        if k in ['left', 'right', 'leftDatapoints', 'rightDatapoints']
            continue

        if v is true
            left[k] = right[k]

    left.tags = tags
    left.datapoints = datapoints

    return left


# # # # # # # # # # # #

# # #
# Tools

# Name comparators
# Return > 0 if similar.
# Check accents, case, parts orders and 'optionnals parts' presence.
compareN = (n1, n2) ->
    [lastName1, firstName1, dummy, dummy, dummy] = n1.split ';'
    [lastName2, firstName2, dummy, dummy, dummy] = n2.split ';'

    simplify = (s) ->
        s = diacritics.asciize s
        return s.toLowerCase()

    lastName1 = simplify lastName1
    firstName1 = simplify firstName1
    lastName2 = simplify lastName2
    firstName2 = simplify firstName2

    if (lastName1 isnt '' or firstName1 isnt '') and
    (lastName2 isnt '' or firstName2 isnt '') and
    (lastName1 is lastName2 and firstName1 is firstName2 or
    lastName1 is firstName2 and firstName1 is lastName2)

        return 1
    else
        return -1


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
