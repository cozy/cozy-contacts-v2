# Dependencies :
# https://github.com/mathiasbynens/quoted-printable
# https://github.com/mathiasbynens/utf8.js
#
# Model
# fn: String # vCard FullName = display name
# (Prefix Given Middle Familly Suffix)
# n: [String] # vCard Name = splitted
# [Familly, Given, Middle, Prefix, Suffix]

exports.nToFN = (n) ->
    if not n
        n = []

    [familly, given, middle, prefix, suffix] = n

    # order parts of name.
    parts = [prefix, given, middle, familly, suffix]
    # remove empty parts
    parts = parts.filter (part) -> part? and part isnt ''

    return parts.join ' '

# Parse n field (splitted) from fn (display).
exports.fnToN = (fn) ->
    if not fn?
        fn = ''
    return ['', fn, '', '', '']


##
# vCard serialisation.
##

exports.escapeText = (s) ->
    if not s?
        return s
    t = s.replace /([,;\\])/ig, "\\$1"
    t = t.replace /\n/g, '\\n'

    return t

exports.unescapeText = (t) ->
    if not t?
        return t
    s = t.replace /\\n/ig, '\n'
    s = s.replace /\\([,;\\])/ig, "$1"

    return s

exports.unquotePrintable = (s) ->
    if not s?
        s = ''
    return utf8.decode quotedPrintable.decode s
