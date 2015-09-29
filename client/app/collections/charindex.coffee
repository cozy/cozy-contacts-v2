{Filtered}  = BackboneProjections
{asciize, alphabet} = require 'lib/diacritics'


module.exports = class CharIndex extends Filtered
    constructor: (underlying, options) ->
        options.comparator = (a, b) ->
            a.attributes.n.localeCompare b.attributes.n
        options.comparator.induced = true

        options.filter = (model) ->
            n = asciize(model.attributes.n).toLowerCase()

            [gn, fn, ...] = n.split ';'
            initial = if gn then gn[0] else if fn then fn[0] else '#'

            if options.char is '#'
                not initial.match alphabet
            else
                options.char is initial

        super
