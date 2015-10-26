{Filtered}  = BackboneProjections
{asciize, alphabet} = require 'lib/diacritics'


module.exports = class CharIndex extends Filtered
    constructor: (underlying, options) ->
        app      = require('application')

        options.filter = (model) ->
            n = asciize(model.attributes.n).toLowerCase()
            if options.filter.sort is 'fn' then [snd, fst, ...] = n.split ';'
            else [fst, snd, ...] = n.split ';'

            initial = if fst then fst[0] else if snd then snd[0] else '#'

            if options.char is '#' then not initial.match alphabet
            else options.char is initial
        options.filter.sort = app.model.get 'sort'

        super

        @stopListening @underlying, 'sort'
        @listenTo underlying, 'sort', -> _.defer =>
            options.filter.sort = app.model.get 'sort'
            @reset @underlying.models.filter @options.filter
