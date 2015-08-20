# see http://stackoverflow.com/a/863865

alphabet = /[\u0041-\u005A\u0061-\u007A]/g

diacritics =
    A:  /[\u00C0-\u00C5]/g
    AE: /[\u00C6]/g
    a:  /[\u00E0-\u00E5]/g
    ae: /[\u00E6]/g
    C:  /[\u00C7]/g
    c:  /[\u00E7]/g
    D:  /[\u00D0]/g
    d:  /[\u00F0]/g
    E:  /[\u00C8-\u00CB]/g
    e:  /[\u00E8-\u00EB]/g
    I:  /[\u00CC-\u00CF]/g
    i:  /[\u00EC-\u00EF]/g
    N:  /[\u00D1]/g
    n:  /[\u00F1]/g
    O:  /[\u00D2-\u00D6\u00D8]/g
    o:  /[\u00F2-\u00F6\u00F8]/g
    OE: /[\u0152]/g
    oe: /[\u0153]/g
    U:  /[\u00D9-\u00DC]/g
    u:  /[\u00F9-\u00FC]/g
    Y:  /[\u00DD]/g
    y:  /[\u00FD\u00FF]/g


asciize = (str) ->
    (str = str.replace dia, letter) for letter, dia of diacritics
    return str


module.exports =
    alphabet:   alphabet
    diacritics: diacritics
    asciize:    asciize
